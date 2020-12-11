# cloud-provider-aws

Simple local-up script to bring up a single-node AWS kuberenetes cluster using our-of-tree AWS provider implementation: https://github.com/kubernetes/cloud-provider-aws.

Based and tested on Fedora public AMI in `eu-central-1` region.

The script will deploy an EC2 instance with ssh access. To configure default variables see [variables.tf](variables.tf). `cloud-init` is used to run a dev script, deploying a cluster. To check the progress of the installation after the is provisioning complete, ssh into the instance and `cat /var/log/cloud-init-output.log`.

# Usage

To deploy:

```bash
export TF_VAR_AWS_REGION=$AWS_REGION
export TF_VAR_AWS_PROFILE=$AWS_PROFILE
export TF_VAR_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export TF_VAR_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
cp terraform.tfvars.json.example terraform.tfvars.json
terraform apply
```

To destroy
```bash
terraform destroy
```

# Prerequisite variables

Those you might want to change or set in [terraform.tfvars.json](terraform.tfvars.json):

- `public_key` - Public ssh key to grant access to the instance.
- `private_key` - Private ssh key to grant access to the instance.
- `cluster` - Name of the kubernetes cluster, to tag the instance with.
- `ami` - Your image AMI for the instance to run.
- `AWS_REGION` - AWS region to deploy ec2 instance and configure cluster, also your environment `TF_VAR_AWS_REGION` by default.
- `AWS_PROFILE` - Your environment `TF_VAR_AWS_PROFILE` by default.
- `AWS_ACCESS_KEY_ID` - Your environment `TF_VAR_AWS_ACCESS_KEY_ID` by default.
- `AWS_SECRET_ACCESS_KEY` - Your environment `TF_VAR_AWS_SECRET_ACCESS_KEY` by default.

# Demo

[![asciicast](https://asciinema.org/a/9QSHP9ZRWvwWNoxEW2rEhLm5m.svg)](https://asciinema.org/a/9QSHP9ZRWvwWNoxEW2rEhLm5m)
