#### CloudFlare to API-Gateway Demo

In this project, we are creating a CloudFlare Route for `api.example.com` to AWS API-Gateway.

This API-Gateway in-turn points to an Application Load Balancer created in AWS. 

Please note, all sections are Pseudo-code type only. Main intention is to point out how it might be realized in Terraform

## Code-Pipeline

We are declaring CodePipeline stages which contain build stages. 

As per the image shown, we are suggesting usage of single CodePipeline for all frontend, and one for all backend activities
