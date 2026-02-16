# FortiSASE Automation 

This repository provides a framework and reference model to automate FortiSASE operations using industry-standard CI/CD tools (Terraform and Jenkins).

# Overview

The code is structured in four basic modules:
- **Auth** - Authentication and authorization management
- **Endpoint** - Endpoint configuration and policies
- **Networking** - Network infrastructure and connectivity
- **Security** - Security policies and rules


## Architecture Reference

For design details and the logic behind the architecture and variables implemented in this code, please refer to the **Unified-SASE Reference Architecture Guide for MSSPs**. 

> 📘 To obtain this document, reach out to your local Fortinet representative.

## Initialization

Run:

```
terraform init
```

Then remove the .template extension on each relevant variable file (in root dir) to create the required tfvars file. Without .auto.tfvars file you won't be able to run terraform.

E.g.: 
```
cp variables_login.auto.tfvars.template variables_login.auto.tfvars
```

Then replace values in such file according to your needs.

You'll need to upload a certificate to FortiSASE, named "server" (it's used in auth module). This step will be automated in future releases.

## Execution

Run it from the root, globally, using:

```
terraform apply -auto-approve
```

Or module by module:

```
terraform apply -auto-approve -target=module.auth
terraform apply -auto-approve -target=module.endpoint
terraform apply -auto-approve -target=module.networking
terraform apply -auto-approve -target=module.security
```

There is also an script ("./run_only_troubleshooting.sh") to help during development and troubleshooting. This files creates some resources/modules individually. 


Note that running "terraform apply" with a target will attempt to create the target and all the objects the target is dependent on. However, using "terraform destroy" with a target will only destroy the target, but not all the objects that were required to create such target.

## Other commands

You can import existing resources in FortiSASE:

```
terraform import fortisase_endpoint_sandbox_profiles.sse_standard "SSE standard"
```

Or refresh the status in case the resource is modified by other party:

```
terraform refresh
```

You can destroy everything:

```
terraform destroy
```

# Pipeline Orchestration

Four Jenkins pipeline files are provided to orchestrate the deployment and teardown of FortiSASE configurations. The pipeline uses a main orchestrator that calls three subjobs, all defined using Jenkinsfiles:

- **Jenkinsfile**: Main orchestrator that calls the three subjobs sequentially
- **Jenkinsfile.clean_infra**: Performs a full cleanup of the FortiSASE instance using API calls (demonstrates API-based management as an alternative to Terraform)
- **Jenkinsfile.configure_infra**: Executes `terraform apply` to deploy the infrastructure
- **Jenkinsfile.destroy_infra**: Executes `terraform destroy` to tear down the infrastructure

## Jenkins Configuration

To set up the pipeline in Jenkins:

1. Create a new Pipeline job
2. Under "Pipeline" section, select "Pipeline script from SCM"
3. Point to this repository
4. Specify the desired Jenkinsfile in the "Script Path" field

**Note:** Each Jenkinsfile can be used independently depending on your workflow requirements.


## Additional notes

As pointed above, the code is structured in four basic modules:
- Auth
- Endpoint
- Networking
- Security

In an attempt to simplify usage, the most relevant variables of each module have been defined in several files in root directory:

variables_<module_name>.tf

For an initial, quick deployment, you have to pay attention to auto.tfvars files and fill/set the variables with the right values.

E.g.: 
variables_login.auto.tfvars
variables_security.auto.tfvars

These files contain the most relevant variables that have to be set for deploying the basic use case (remember they have to be copied from .template and filled with your own values).
However, it's suggested to review the content of each module, include all resources defined and adapt them to your needs, as you might need alternative definitions or additional resources.

E.g.: networking module contains only two service connections. If your scenario requires more, you'll need to add more resources of "service connections" type to fulfil your needs.


You'll note that each module contains soft links pointing to variable files in root. This is intentional, aiming to have all variables centralized in root instead of having them in the modules, for easy access.

The right way to run terraform should be "terraform apply", and it should create all resources in a single shot, without additional human intervention.