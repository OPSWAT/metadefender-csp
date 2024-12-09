######### autoScalingGroup Core #########

resource "aws_placement_group" "metadefender_group" {
  count    = var.AUTOSCALING ? 1 : 0
  name     = "metadefender-${var.ENV_NAME}-${var.APP_NAME}"
  strategy = "cluster"
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = [var.PRODUCT_ID]
  }
}

data "template_file" "mdss_user_data_script" {
  count = var.DEPLOY_MDSS && (var.DEPLOY_MDSS_DOCUMENTDB || var.DEPLOY_MDSS_AMAZONMQ || var.DEPLOY_MDSS_ELASTICACHE) ? 1 : 0
  template = <<-EOT
    #!/bin/bash
    
    %{ if var.MDSS_DOCUMENTDB_SECRET_ARN != null }
    aws secretsmanager get-secret-value --secret-id ${var.MDSS_DOCUMENTDB_SECRET_ARN} --region ${var.MD_REGION} --query SecretString --output text | jq -r '.mongo_uri' | awk '{print "MONGO_URL="$0}' >> /etc/mdss/customer.env
    %{ endif }
    %{ if var.MDSS_AMAZONMQ_SECRET_ARN != null }
    aws secretsmanager get-secret-value --secret-id ${var.MDSS_AMAZONMQ_SECRET_ARN} --query SecretString --output text --region ${var.MD_REGION} | jq -r '.uri' | awk '{print "RABBITMQ_URI="$0}' >> /etc/mdss/customer.env
    %{ endif }
    %{ if var.MDSS_ELASTICACHE_SECRET_ARN != null }
    aws secretsmanager get-secret-value --secret-id ${var.MDSS_ELASTICACHE_SECRET_ARN} --query SecretString --output text --region ${var.MD_REGION} | jq -r '.uri' | awk '{print "CACHE_SERVICE_URI="$0}' >> /etc/mdss/customer.env
    %{ endif }
    sudo docker rm -f $(docker ps -a -q)
    sudo mdss -c start
    touch /etc/mdss/finished_user_data
  EOT
}

data "template_file" "core_icap_user_data" {
  count = var.DEPLOY_CORE || var.DEPLOY_ICAP ? 1 : 0
  template = <<-EOT
    %{ if var.LICENSE_KEY != "" }
    LICENSE_KEY=${var.LICENSE_KEY}
    %{ endif }
    %{ if var.APIKEY != "" }
    APIKEY=${var.APIKEY}
    %{ endif }
  EOT
}

resource "aws_launch_template" "template" {
  name_prefix   = "${var.APP_NAME}-template"
  image_id      = data.aws_ami.ami.id
  instance_type = var.INSTANCE_TYPE 
  vpc_security_group_ids = [var.SG_ID]
  # Inline user_data script (optional)
  user_data = var.DEPLOY_MDSS && (var.DEPLOY_MDSS_DOCUMENTDB || var.DEPLOY_MDSS_AMAZONMQ || var.DEPLOY_MDSS_ELASTICACHE) ? base64encode(data.template_file.mdss_user_data_script[0].rendered) : var.DEPLOY_CORE || var.DEPLOY_ICAP ? base64encode(data.template_file.core_icap_user_data[0].rendered) : null

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted = true
      volume_size = 100   ## This has to be greater than the RAM memory to accommodate the total RAM for the instance type
    }
  }

  iam_instance_profile {
    arn = var.DEPLOY_MDSS && (var.DEPLOY_MDSS_DOCUMENTDB || var.DEPLOY_MDSS_AMAZONMQ || var.DEPLOY_MDSS_ELASTICACHE) ? var.MDSS_IAM_INSTANCE_PROFILE_ARN : null
  }

}

#### SINGLE EC2 ###

resource "aws_instance" "metadefender-instance" {
  count               = var.AUTOSCALING ? 0 : 1

  subnet_id = var.PUBLIC ? var.PUB_SUBNET_IDS[0] : var.PRIV_SUBNET_IDS[0]
  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
  tags = {
    Name = "${var.ENV_NAME}-${var.APP_NAME}-instance"
  }
}

resource "aws_eip" "metadefender_eip" {
  count = var.PUBLIC && var.AUTOSCALING != true ? 1 : 0
}

resource "aws_eip_association" "eip_assoc" {
  count         = var.PUBLIC && var.AUTOSCALING != true ? 1 : 0
  instance_id   = aws_instance.metadefender-instance[0].id
  allocation_id = aws_eip.metadefender_eip[0].id
  depends_on    = [aws_instance.metadefender-instance]
}

### Load Balancer for ASG

resource "aws_lb" "asg-lb" {
  count              = var.AUTOSCALING ? 1 : 0
  name               = "lb-${var.ENV_NAME}-${var.APP_NAME}"
  internal           = var.PUBLIC ? false : true
  load_balancer_type = "network"
  subnets            = var.PUBLIC ? var.PUB_SUBNET_IDS : var.PRIV_SUBNET_IDS
  security_groups    = [var.SG_ID]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "lb-target" {
  count                     = var.AUTOSCALING ? 1 : 0
  name = "lb-tgt-${var.APP_NAME}-${var.ENV_NAME}"
  port = var.APP_PORT
  protocol = "TCP"
  vpc_id = var.VPC_ID
  health_check {
    path    = var.DEPLOY_MDSS ? "/" : "/readyz"
    matcher = 200
  }

  stickiness {
    type = "source_ip"
    enabled = true
  }
}

resource "aws_lb_listener" "alb-target-listener-core" {
  count                     = var.AUTOSCALING ? 1 : 0
  load_balancer_arn = aws_lb.asg-lb[0].arn
  port = var.APP_PORT
  protocol = "TCP"
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lb-target[0].arn
  }
}


### ASG ###

resource "aws_autoscaling_group" "asg" {
  count                     = var.AUTOSCALING ? 1 : 0
  name                      = "${var.ENV_NAME}-${var.APP_NAME}-asg"
  max_size                  = 2
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  vpc_zone_identifier       = var.PRIV_SUBNET_IDS
  target_group_arns = [aws_lb_target_group.lb-target[0].arn]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.DEPLOY_MDSS || !var.LICENSE_AUTOMATION_LAMBDA ? [] : [1]
    content{
      name                 = "initial_hook"
      default_result       = "ABANDON"
      heartbeat_timeout    = 300
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode({
        action = "activate_initial"
      })
    }
    
  }

  dynamic "warm_pool" {
    for_each = var.WARM_POOL_ENABLED ? [1] : []
    content {
      pool_state                  = "Stopped"
      min_size                    = 0
      max_group_prepared_capacity = -1

      instance_reuse_policy {
        reuse_on_scale_in = true
      }
    }
  }
  
  timeouts {
    delete = "15m"
  }

}

resource "aws_autoscaling_lifecycle_hook" "instance_terminating_hook" {
  count                  = var.AUTOSCALING && var.LICENSE_AUTOMATION_LAMBDA ? 1 : 0
  name                   = "instance_terminating_hook-${var.ENV_NAME}"
  autoscaling_group_name = aws_autoscaling_group.asg[0].name
  default_result         = "ABANDON"
  heartbeat_timeout      = 60
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"

  notification_metadata = jsonencode({
      action = "register_hot_backup"
  })

}