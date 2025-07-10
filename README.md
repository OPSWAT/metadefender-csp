# MetaDefender Deployed on Cloud Service Providers

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

OPSWAT products are adapting year over year for our customers to get advantage of the different ways to deploy the MetaDefender products. This project covers different deployment options and automations for the OPSWAT products that are supported to be deployed in different Cloud Service Providers (CSPs). We provide you with some architecture recommendations for the main cloud providers to host MetaDefender products being deployed as single instance or with multiple instances and load balancing the request. All these automations are using the images published in the different CSP marketplaces. 

Main Metadefender Core documentation pages:

* [AWS CSP Recommended Architectures](https://docs.opswat.com/mdcore/cloud-deployment/recommended-architectures-in-aws)

On MetaDefender Core docs you can find examples on how to integrate MetaDefender Core with MetaDefender ICAP Server or Storage Security but each product also has its own documentation pages with recommendation for each CSP

* [AWS CSP Recommended Architectures for ICAP](https://docs.opswat.com/mdcore/cloud-deployment/recommended-architectures-in-aws)
* [AWS CSP Recommended Architectures for Storage Security](https://docs.opswat.com/mdss/deployment-guide)

In case of being interested in deploying any of OPSWAT products to a Kubernetes cluster please check [metadefender-k8s](https://github.com/OPSWAT/metadefender-k8s) repository

<p align="right">(<a href="#top">back to top</a>)</p>

### Current CSPs automation developed

The main goal of this project is to develop the code to automate the creation of the different resources needed in the different CSPs to get to the best usage of the OPSWAT applications. Current supported automations will improve release by release, together with new ones that are on RoadMap 

- AWS
- Azure
- GCP ( On RoadMap)

<!-- GETTING STARTED -->
## Getting Started

There is a folder for each the CSP to deploy the applications. Inside each CSP folder there is either an automation to deploy a single instance or the service to have multiple instances. 

- Go to each CSP folder and see README file 
- Contact sales to get your license key to activate the different applications

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/newGreatEnhancement`)
3. Commit your Changes (`git commit -m 'Add some new great enhancement'`)
4. Push to the Branch (`git push origin feature/newGreatEnhancement`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- LICENSE -->
## Licensing

For running MetaDefender products you will need to set up the license needed for each of the products, in case of not having such license key please contact Sales: sales-inquiry@opswat.com. 

In case of having any issue with your license please contact [Support](https://www.opswat.com/support)

For other [questions](https://www.opswat.com/contact)


<p align="right">(<a href="#top">back to top</a>)</p>


<!-- CONTACT -->
## Contact

**OPSWAT Contact Information**

* Sales: sales-inquiry@opswat.com
* Support: https://www.opswat.com/support
* Contact US: https://www.opswat.com/contact

MetaDefender Core Documentation: [https://docs.opswat.com/mdcore](https://docs.opswat.com/mdcore)
MetaDefender ICAP Server Documentation: [https://docs.opswat.com/mdicap](https://docs.opswat.com/mdicap)
MetaDefender for Secure Storage Documentation: [https://docs.opswat.com/mdss](https://docs.opswat.com/mdss)

<p align="right">(<a href="#top">back to top</a>)</p>
