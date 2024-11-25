# App deployment assignment

There is a published (linux/amd64) docker image at `immesys/example-app:latest`. You can see the source code for this application in the `service` directory, and the dockerfile that built it.

The task for this assignment is to deploy this application, following the requirements. There are many aspects of the deployment that are unspecified, and you should pick good, simple choices for them. In the follow-up call, we will walk through your choices and you can share your rationale.

## Requirements

The goal is to deploy this application on EKS on AWS. The EKS cluster should be created/configured using Terraform, and the application should be deployed using Helm. The application requires a configuration file (located in `/etc/appd/config.yaml`) that should look like:

```yaml
shopName: $SHOPNAME
```

where $SHOPNAME should be a variable that is asked for by terraform (or is present in a terraform vars file). This config file is a bit artificial, but it is representative of a variable that needs to be communicated from the Terraform step through to the final deployment, which is a common pattern.

Ultimately, we should be able to view the app on a public address (a DNS entry with HTTPS would be nice, there is a hosted zone available in route53 on your AWS account).

Aside from the above requirements, which you need to follow, you are free to choose other aspects of the solution based on what you think is best. This is not a trick question, it's just seeing how you approach a simple problem of provisioning some kubernetes infrastructure and deploying an app to it.

When picking patterns for this assignment, think of what you would pick if this were a real app being deployed into production as part of a CI/CD pipeline.

## Credentials
In case you don't have an AWS account available to you, you should have been emailed some credentials to an empty AWS account. You can use this to test/develop your terraform script, but please tear down your resources when you are done. We will walk through the deployment together on our follow up call using the terraform files and helm chart you developed during this assignment

## Submission
Please submit your terraform files, helm chart and any other resources you need for your deployment pattern to the git repo following the instructions from CodeSubmit. 