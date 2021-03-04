# Terraforming AWS [![build-status](https://infra.ci.cf-app.com/api/v1/teams/main/pipelines/terraforming-aws/jobs/deploy-pas/badge)](https://infra.ci.cf-app.com/teams/main/pipelines/terraforming-aws)

## What is this?

Set of terraform modules for deploying Ops Manager, PAS and PKS infrastructure requirements like:

- Friendly DNS entries in Route53
- A RDS instance (optional)
- A Virtual Private Network (VPC), subnets, Security Groups
- Necessary s3 buckets
- NAT Gateway services
- Network Load Balancers
- An IAM User with proper permissions
- Tagged resources

Note: This is not an exhaustive list of resources created, this will vary depending of your arguments and what you're deploying.

## Prerequisites

- [Docker](https://docs.docker.com/docker-for-mac/install/)
- jq

```bash
brew update
brew install jq
```

## Creating Service Account
A service account with the following permissions and role is necessary.

### AWS Permissions
- AmazonEC2FullAccess
- AmazonRDSFullAccess
- AmazonRoute53FullAccess
- AmazonS3FullAccess
- AmazonVPCFullAccess
- IAMFullAccess
- AWSKeyManagementServicePowerUser

Note: You will also need to create a custom policy as the following and add to
      the same user:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "KMSKeyDeletionAndUpdate",
            "Effect": "Allow",
            "Action": [
                "kms:UpdateKeyDescription",
                "kms:ScheduleKeyDeletion"
            ],
            "Resource": "*"
        }
    ]
}
```

### AWS Account and Secret Key
The account key and secret key should be exported in the environment:
```bash
export AWS_ACCESS_KEY_ID = "aws account access keh id"
export AWS_SECRET_ACCESS_KEY = "aws account secret key"
```

## Deploying Infrastructure

### Generate environment directory
Use the `./scripts/config-new-foundation.sh` script to generate a new environment directory.

```bash
$ ./scripts/config-new-foundation.sh <new-foundation-name>
```

A new directory named `new-foundation-name` will be created in your current directory. Certificates and a vars file will be created.

#### Var File Created

The *terraform.tfvars* default vars file will resemble what is shown below. These values will be used when terraform creates the environment.

If you want to change any of *env_name*, *ops_manager_image_uri*, *location*, *dns_suffix* or  *dns_subdomain* in terraform.tfvars, now is the time. There are defaults set that my not match your needs.

```bash
access_key         = "aws access key"
secret_key         = "aws secret key"
region             = "us-west-2"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
ops_manager_ami    = "ami-02ab20729afd10cf9"

env_name              = "banana"
dns_suffix            = "domain.com"

# optional. if left blank, will default to the pattern `env_name.dns_suffix`.
dns_subdomain         = ""
```

#### Variables

These are the valid variables that can be configured in *terraform.tfvars*

- env_name: **(required)** An arbitrary unique name for namespacing resources
- region: **(required)** Region you want to deploy your resources to
- availability_zones: **(required)** List of AZs you want to deploy to
- dns_suffix: **(required)** Domain to add environment subdomain to
- hosted_zone: **(optional)** Parent domain *already* managed by Route53. If specified, the DNS records will be added to this Route53 zone instead of a new zone.
- ssl_cert: **(optional)** SSL certificate for HTTP load balancer configuration. Required unless `ssl_ca_cert` is specified.
- ssl_private_key: **(optional)** Private key for above SSL certificate. Required unless `ssl_ca_cert` is specified.
- ssl_ca_cert: **(optional)** SSL CA certificate used to generate self-signed HTTP load balancer certificate. Required unless `ssl_cert` is specified.
- ssl_ca_private_key: **(optional)** Private key for above SSL CA certificate. Required unless `ssl_cert` is specified.
- tags: **(optional)** A map of AWS tags that are applied to the created resources. By default, the following tags are set: Application = Cloud Foundry, Environment = $env_name
- vpc_cidr: **(default: 10.0.0.0/16)** Internal CIDR block for the AWS VPC.
- use_route53: **(default: true)** Controls whether or not Route53 DNS resources are created.
- use_ssh_routes: **(default: true)** Enable ssh routing
- use_tcp_routes: **(default: true)** Controls whether or not tcp routing is enabled.

##### Ops Manager (optional)
- ops_manager_ami: **(optional)**  Ops Manager AMI, get the right AMI according to your region from the AWS guide downloaded from [Pivotal Network](https://network.pivotal.io/products/ops-manager) (if set to `""` no Ops Manager VM will be created)
- optional_ops_manager_ami: **(optional)**  Additional Ops Manager AMI, get the right AMI according to your region from the AWS guide downloaded from [Pivotal Network](https://network.pivotal.io/products/ops-manager)
- ops_manager_instance_type: **(default: m4.large)** Ops Manager instance type
- ops_manager_private: **(default: false)** Set to true if you want Ops Manager deployed in a private subnet instead of a public subnet

##### S3 Buckets (optional) (PAS only)
- create_backup_pas_buckets: **(default: false)**
- create_versioned_pas_buckets: **(default: false)**

##### RDS (optional)
- rds_instance_count: **(default: 0)** Whether or not you would like an RDS for your deployment
- rds_instance_class: **(default: db.m4.large)** Size of the RDS to deploy
- rds_db_username: **(default: admin)** Username for RDS authentication

##### Isolation Segments (optional)  (PAS only)
- create_isoseg_resources **(optional)** Set to 1 to create HTTP load-balancer across 3 zones for isolation segments.
- isoseg_ssl_cert: **(optional)** SSL certificate for Iso Seg HTTP load balancer configuration. Required unless `isoseg_ssl_ca_cert` is specified.
- isoseg_ssl_private_key: **(optional)** Private key for above SSL certificate. Required unless `isoseg_ssl_ca_cert` is specified.
- isoseg_ssl_ca_cert: **(optional)** SSL CA certificate used to generate self-signed Iso Seg HTTP load balancer certificate. Required unless `isoseg_ssl_cert` is specified.
- isoseg_ssl_ca_private_key: **(optional)** Private key for above SSL CA certificate. Required unless `isoseg_ssl_cert` is specified.

#### Notes

You can choose whether you would like an RDS or not. By default we have
`rds_instance_count` set to `0` but setting it to `1` will deploy an RDS instance.

Note: RDS instances take a long time to deploy, keep that in mind. They're not required.

## Running

Note: please make sure you have created/edited the `terraform.tfvars` file above as mentioned.

The next step should be run from within the environment directory created with `scripts/config-new-foundation.sh`

### Standing up environment

Run `scripts/tf-new-director.sh` from within the environment directory created with `scripts/config-new-foundation.sh`

```bash
cd <new-foundation-name>
../scripts/tf-new-director.sh
```

At the end you should see something like:

```bash
...
ssl_cert = <sensitive>
ssl_private_key = <sensitive>
subscription_id = <sensitive>
sys_domain = sys.csb-azure-pas5.envs.cfplatformeng.com
tcp_domain = tcp.csb-azure-pas5.envs.cfplatformeng.com
tcp_lb_name = csb-azure-pas5-tcp-lb
tenant_id = <sensitive>
web_lb_name = csb-azure-pas5-web-lb
Add these nameservers for environment
ns2-03.azure-dns.net.,
ns3-03.azure-dns.org.,
ns1-03.azure-dns.com.,
ns4-03.azure-dns.info.
```

#### DNS Records

You'll need to add those name servers to the DNS system hosting your domain name. 

### Configuring the Director

Use `scripts/configure-director` to finish configuration of the director

```bash
../scripts/configure-director <om-password>
```

*om-password* will be the admin password Ops Man.

### Tearing down environment

**Note:** This will only destroy resources deployed by Terraform. You will need to clean up anything deployed on top of that infrastructure yourself (e.g. by running `om delete-installation`)

```bash
../scripts/tf-destroy.sh
```

