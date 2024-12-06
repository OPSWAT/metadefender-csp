import { AutoScalingClient, CompleteLifecycleActionCommand } from "@aws-sdk/client-auto-scaling";
import { EC2Client, DescribeInstancesCommand } from "@aws-sdk/client-ec2"; // ES Modules import
import {SSMClient, PutParameterCommand, ParameterType,DeleteParameterCommand,GetParameterCommand,GetParametersByPathCommand } from "@aws-sdk/client-ssm";
import { createRequire } from 'module';
const require = createRequire(import.meta.url);

const http = require('http');
const https = require('https');
let retries = 0;
const MAX_RETRY = 10;
const parameter_name = 'metadefender-core';

// Define a sleep function that returns a promise
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function httpRequest(options,body) {

  console.log("Options before send: ",options);
  console.log("Body before send: ",body);

  if (retries > 0){
    console.log("Sleep for Core to be ready");
    await sleep(30000); // Wait for ten seconds
  }


  return new Promise((resolve, reject) => {

    const req = http.request(options, (res) => {
      console.log(`STATUS: ${res.statusCode}`);
      res.setEncoding('utf8');
      let rawData = "";
      res.on('data', (chunk) => {
        console.log(`RESPONSE BODY: ${chunk}`);
        rawData += chunk;
      });
      res.on('end', () => {
        try {
          
          if (res.statusCode == 200){
            let json_data = JSON.parse(rawData);
            console.log('Status 200, Json_data ',json_data);
            retries = 0;
            resolve(json_data);
          }
          else {
            console.log("Request failed: ",res.statusCode);
            if ((res.statusCode === 500 || res.statusCode === 403) && retries < MAX_RETRY) {

              retries += 1;
              console.log("Starting retry number ",retries);
              
              resolve(httpRequest(options,body));

            }else{

              reject(new Error(rawData));
            }
          }
          
        } catch (err) {
          console.log("ERROR RES: ",err);
          reject(new Error(err));
        }
      });
    });

    
    req.on('error', async (e) => {
      console.error(`problem with request: ${e.message}`);
      // Check if retry is needed
      if ((e.code === 'ECONNREFUSED' || e) && retries < MAX_RETRY) {
        retries += 1;
        console.log("Starting retry number ",retries);
        
        resolve(httpRequest(options,body));
      }else{
        reject(new Error(e.message));
      }
    });
    
    // Write data to request body
    req.write(body);
    console.log("REQUEST SENT: ",req);

    req.end();

  });
}

async function httpsRequest(options,body) {

  console.log("Options before send: ",options);
  console.log("Body before send: ",body);

  if (retries > 0){
    console.log("Sleep for Core to be ready");
    await sleep(30000); // Wait for ten seconds
  }


  return new Promise((resolve, reject) => {

    const req = https.request(options, (res) => {
      console.log(`STATUS: ${res.statusCode}`);
      res.setEncoding('utf8');
      let rawData = "";
      res.on('data', (chunk) => {
        console.log(`RESPONSE BODY: ${chunk}`);
        rawData += chunk;
      });
      res.on('end', () => {
        try {
          
          if (res.statusCode == 200){
            let json_data = JSON.parse(rawData);
            console.log('Status 200, Json_data ',json_data);
            retries = 0;
            resolve(json_data);
          }
          else {
            console.log("Request failed: ",res.statusCode);
            if ((res.statusCode === 500 ) && retries < MAX_RETRY) {

              retries += 1;
              console.log("Starting retry number ",retries);
              
              resolve(httpRequest(options,body));

            }else{

              reject(new Error(rawData));
            }
          }
          
        } catch (err) {
          console.log("ERROR RES: ",err);
          reject(new Error(err));
        }
      });
    });

    
    req.on('error', async (e) => {
      console.error(`problem with request: ${e.message}`);
      // Check if retry is needed
      if ((e.code === 'ECONNREFUSED' || e) && retries < MAX_RETRY) {
        retries += 1;
        console.log("Starting retry number ",retries);
        
        resolve(httpRequest(options,body));
      }else{
        reject(new Error(e.message));
      }
    });
    
    // Write data to request body
    req.write(body);
    console.log("REQUEST SENT: ",req);

    req.end();

  });
}

async function loginGetSessionId(privateIp,body) {
  var options = {
    hostname: `${privateIp}`,
    port: 8008,
    path: '/login',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body),
    },
  };

  return await httpRequest(options,body);
  
}

async function changePassword(privateIp,apikey,body) {
  var options = {
    hostname: `${privateIp}`,
    port: 8008,
    path: '/user/changepassword',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body),
      'apikey': `${apikey}`,
    },
  };

   return await httpRequest(options,body);

}

async function setUpApiKey(privateIp,apikey,body) {
  var options = {
    hostname: `${privateIp}`,
    port: 8008,
    path: '/admin/user/2',
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body),
      'apikey': `${apikey}`,
    },
  };

   return await httpRequest(options,body);

}

async function getDeploymentID(privateIp,apikey,body) {
  var options = {
    hostname: `${privateIp}`,
    port: 8008,
    path: '/admin/license',
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body),
      'apikey': `${apikey}`,
    },
  };

   return await httpRequest(options,body);

}

async function activateCore(privateIp,apikey,body) {
  var options = {
    hostname: `${privateIp}`,
    port: 8008,
    path: '/admin/license/activation',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body),
      'apikey': `${apikey}`,
    },
  };

   return await httpRequest(options,body);

}

async function deactivateCore(licenseKey,deploymentIdToDeactivate) {
  var options = {
    hostname: 'activation.dl.opswat.com',
    port: 443,
    path: `/deactivation?key=${licenseKey}&deployment=${deploymentIdToDeactivate}`,
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  };

   return await httpsRequest(options,"");

}

export const handler = async(event) => {

  var startTime = performance.now();

  console.log('LogAutoScalingEvent');
  console.log('Received event:', JSON.stringify(event, null, 2));

  const licenseKey = process.env.LICENSE_KEY;
  const apikey = process.env.APIKEY;
  const core_password = process.env.CORE_PWD;

  //const core_os_server = process.env.CORE_OS_SERVER;
  console.log("License Key: ",licenseKey);
  console.log("APIKEY: ",apikey);
  console.log("Core Admin User Password: ", core_password);

  const instance_id = event.detail.EC2InstanceId;
  console.log("INSTANCE ID: ",instance_id);
  const event_origin = event.detail.Origin;
  console.log("ORIGIN: ",event_origin);
  const event_destination = event.detail.Destination;
  console.log("DESTINATION: ",event_destination);


  //Init SSM Module
  const clientSSM = new SSMClient({ region: event.region });

  //Init AutoScaling Module
  var autoscaling = new AutoScalingClient({ region: event.region });
  var eventDetail = event.detail;
  var params = {
    AutoScalingGroupName: eventDetail['AutoScalingGroupName'], /* required */
    LifecycleActionResult: 'CONTINUE', /* required */
    LifecycleHookName: eventDetail['LifecycleHookName'], /* required */
    InstanceId: eventDetail['EC2InstanceId'],
    LifecycleActionToken: eventDetail['LifecycleActionToken']
  };
  const command = new CompleteLifecycleActionCommand(params);


  //Init EC2 Module
  const client = new EC2Client({ region: event.region });

  // Get IP Address from EC2 that triggered the event
  var input = { // DescribeAddressesRequest
    InstanceIds: [ // Instances ID filter
      instance_id,
    ]
  };

  const commandDescribe = new DescribeInstancesCommand(input);

  try {
    var getIpStart = performance.now();

    var responseDescribe = await client.send(commandDescribe);
    console.log('Response describe EC2:', JSON.stringify(responseDescribe, null, 2));
    var PrivateIpAddress = responseDescribe.Reservations[0].Instances[0].PrivateIpAddress;
    console.log('Private IP Address EC2: ',PrivateIpAddress);

    var getIpEnd = performance.now();

    console.log(`Get IP from EC2 took ${getIpEnd - getIpStart} milliseconds`);

    var response;
    var sessionId;

    var getConnectionWithCoreStart = performance.now();

    if (event_origin == "EC2" || apikey == ""){
      // GET Session ID to access Core API
      let loginData = JSON.stringify({
        'user': 'admin',
        'password': `${instance_id}`,
        });
      let res_login = await loginGetSessionId(PrivateIpAddress,loginData);
      sessionId = res_login.session_id;
      console.log('SessionID: ', sessionId);
      let getConnectionWithCoreEnd = performance.now();
      console.log(`Connect to the Core API took ${getConnectionWithCoreEnd - getConnectionWithCoreStart} milliseconds`);
    }else {
      sessionId = apikey;
    }

    // Licensing Action to be taken
    switch(event_origin) {
      case "EC2":
        
        // Set Up APIKEY
        if (apikey != "" ){
          console.log('Set up APIKEY');
        
          let resultApiKey = await setUpApiKey(PrivateIpAddress,sessionId,JSON.stringify({
            'api_key': `${apikey}`
          }));
          console.log('result resultApiKey: ', resultApiKey);
          sessionId = apikey;
        
        }

        // Change Core password
        if ( core_password != "" && core_password != "admin"){

          console.log('Change User Admin Password');
        
          let resultChangePassword = await changePassword(PrivateIpAddress,sessionId,JSON.stringify({
            'old_password': `${instance_id}`,
            'new_password': `${core_password}`
          }));
          console.log('result resultChangePassword: ', resultChangePassword);
        
        }


        if (event_destination == "AutoScalingGroup"){
          
          // First Activation Step
          console.log('First Activation Step');
          
          let activateCoreStart = performance.now();

          let resultActivation = await activateCore(PrivateIpAddress,sessionId,JSON.stringify({
            'activationKey': `${licenseKey}`,
            'quantity': 1,
            'comment': `Activation for ${instance_id}`,
          }));
          console.log('result Activation: ', resultActivation);

          let res_deployment = await getDeploymentID(PrivateIpAddress,sessionId,JSON.stringify({}));
          console.log('result Deployment: ', res_deployment);
          console.log('DeploymentID: ', res_deployment.deployment);
          (await clientSSM.send(new PutParameterCommand({ Name: `/${parameter_name}/activated/${instance_id}`, Value: `${res_deployment.deployment}`, Overwrite: true, Type: ParameterType.STRING_LIST})));
          
          let activateCoreEnd = performance.now();
          console.log(`Activate Core took ${activateCoreEnd - activateCoreStart} milliseconds`);
        
        } else if (event_destination == "WarmPool"){

          console.log(`Core will be kept deactivated in warm pool`);

        }

        break;
      case "AutoScalingGroup":
        
          // Deactivate Step
          console.log('Deactivate Core');
          let res_get_parameter = await clientSSM.send(new GetParameterCommand({ Name: `/${parameter_name}/activated/${instance_id}`}))
        
          console.log("RES GET PARAMETER", res_get_parameter);
          console.log("RES GET PARAMETER VALUE", res_get_parameter.Parameter.Value);
        
          let deploymentIdToDeactivate = res_get_parameter.Parameter.Value.split(',')[0];
        
          let res_deactivate = await deactivateCore(licenseKey,deploymentIdToDeactivate);
          console.log("RES DEACTIVATE", res_deactivate);
        
          let res_delete_parameter = await clientSSM.send(new DeleteParameterCommand({ Name: `/${parameter_name}/activated/${instance_id}`}))
          console.log("RES DELETE PARAMETER", res_delete_parameter);

        break;
      case "WarmPool":

          if (event_destination == "AutoScalingGroup"){
            // First Activation Step
            console.log('Activation Step');

            let activateCoreStart = performance.now();
          
            let resultActivation = await activateCore(PrivateIpAddress,sessionId,JSON.stringify({
              'activationKey': `${licenseKey}`,
              'quantity': 1,
              'comment': `Activation for ${instance_id}`,
            }));
            console.log('result Activation: ', resultActivation);
          
            let res_deployment = await getDeploymentID(PrivateIpAddress,sessionId,JSON.stringify({}));
            console.log('result Deployment: ', res_deployment);
            console.log('DeploymentID: ', res_deployment.deployment);
            (await clientSSM.send(new PutParameterCommand({ Name: `/${parameter_name}/activated/${instance_id}`, Value: `${res_deployment.deployment}`, Overwrite: true, Type: ParameterType.STRING_LIST})));

            let activateCoreEnd = performance.now();
            console.log(`Activate Core took ${activateCoreEnd - activateCoreStart} milliseconds`);
          
          } else if (event_destination == "EC2"){
          
            console.log(`Core was already deactivated before being terminated`);
          
          }
        
        break;
      default:
        console.log('LifeCycleHook Origin does not match the options');
        response = {
          statusCode: 500,
          body: JSON.stringify('ERROR Completing LifeCycle Action, Origin does not match'),
        };
    }

    // Complete lifecycle
    var data = await autoscaling.send(command);
    console.log(data); // successful response
    response = {
      statusCode: 200,
      body: JSON.stringify('SUCCESS'),
    };
    
  } catch (err) {
    console.error(err);
    console.log(err, err.stack); // an error occurred
    response = {
      statusCode: 500,
      body: JSON.stringify('ERROR'),
    };
  }

  var endTime = performance.now();

  console.log("Cycle Completed ");

  console.log(`Lambda function took ${endTime - startTime} milliseconds`);

  return response;
};