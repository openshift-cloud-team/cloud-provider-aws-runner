# cloud-provider-aws

Simple local-up script to bring up a single-node AWS kuberenetes cluster using our-of-tree AWS provider implementation: https://github.com/kubernetes/cloud-provider-aws

Based on Fedora 32 public AMI.

The script will deploy an EC2 instance with ssh access. To configure default variables see [terraform.tfvars.json](terraform.tfvars.json).
# Usage

To deploy:

```bash
$ terraform apply
```

To destroy
```bash
$ terraform destroy
```
