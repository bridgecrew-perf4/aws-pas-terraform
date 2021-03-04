#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export PROJECT_DIR="${SCRIPT_DIR}/.."

mkdir "${PROJECT_DIR}/${1}"

pushd "${PROJECT_DIR}/${1}"

DNS_SUFFIX=envs.cfplatformeng.com

"${SCRIPT_DIR}/gen-cert.sh" "${1}.${DNS_SUFFIX}" > /dev/null

SSL_CERT=$(cat "${1}.${DNS_SUFFIX}.crt")
SSL_KEY=$(cat "${1}.${DNS_SUFFIX}.key")

cat > ./terraform.tfvars <<EOF
access_key         = "${AWS_ACCESS_KEY_ID}"
secret_key         = "${AWS_SECRET_ACCESS_KEY}"
region             = "${AWS_REGION:-us-west-2}"
availability_zones = ["${AWS_REGION:-us-west-2}a", "${AWS_REGION:-us-west-2}b", "${AWS_REGION:-us-west-2}c"]
ops_manager_ami    = "${OPSMAN_AMI:-ami-02ab20729afd10cf9}"

env_name              = "${1}"
dns_suffix            = "${DNS_SUFFIX}"

dns_subdomain         = ""

ssl_cert = <<SSL_CERT
${SSL_CERT}
SSL_CERT

ssl_private_key = <<SSL_KEY
${SSL_KEY}
SSL_KEY
EOF

cp ../terraforming-pas/*.tf .

popd


# 2.10.8
# • ap-east-1: ** ami-0aa860655d84ea285 **
# • ap-northeast-1: ** ami-081828072434ba674 **
# • ap-northeast-2: ** ami-0dd1e18d499b9c459 **
# • ap-south-1: ** ami-0d030ec1709de23fc **
# • ap-southeast-1: ** ami-0f563de1dbf74c344 **
# • ap-southeast-2: ** ami-0e4e4ee8fe5b04a99 **
# • ca-central-1: ** ami-09c15ac4f61c3b96c **
# • cn-north-1: ** ami-0eb8c80cd00343b31 **
# • eu-central-1: ** ami-010b12f1713f56bc4 **
# • eu-north-1: ** ami-0b94a266c9774f2cf **
# • eu-west-1: ** ami-0f73af3cc09c2bd40 **
# • eu-west-2: ** ami-0f11af311df1ad002 **
# • eu-west-3: ** ami-0d9e8df13a4e4edd1 **
# • sa-east-1: ** ami-05583292b605e9754 **
# • us-east-1: ** ami-05015bde95026a5ea **
# • us-east-2: ** ami-03be4e51778844cd3 **
# • us-gov-west-1: ** ami-0e8e3806ce29eab10 **
# • us-west-1: ** ami-0f8361addcd47e1cb **
# • us-west-2: ** ami-02ab20729afd10cf9 **

# 2.9.17
# • ap-east-1: ** ami-0db6b01a9de48e901 **
# • ap-northeast-1: ** ami-0f0619c1fc16a9a9f **
# • ap-northeast-2: ** ami-0d3ff6d2b8bfc9c16 **
# • ap-south-1: ** ami-06f9e7b3d6377d9f5 **
# • ap-southeast-1: ** ami-01b605e9933298bd7 **
# • ap-southeast-2: ** ami-0f2c03e7c3eece85e **
# • ca-central-1: ** ami-0cf76c24e0bf51f80 **
# • cn-north-1: ** ami-06304e0cd3bc5bc01 **
# • eu-central-1: ** ami-00104930efdacbc4f **
# • eu-north-1: ** ami-02d8fdfb308295738 **
# • eu-west-1: ** ami-003435c79b52fd1a5 **
# • eu-west-2: ** ami-03917af7be2c89fcd **
# • eu-west-3: ** ami-00411ead9b0fad474 **
# • sa-east-1: ** ami-0695201c78c06b0ae **
# • us-east-1: ** ami-04a4a2f01b12ca92c **
# • us-east-2: ** ami-07c9968f34ff444cf **
# • us-gov-west-1: ** ami-00118be684222e5ad **
# • us-west-1: ** ami-0865b2073e55a9d9c **
# • us-west-2: ** ami-08f55157822aeaea5 **

# 2.8.15
# • ap-east-1: ** ami-032a4442c4efea974 **
# • ap-northeast-1: ** ami-034ece4b3f42e54da **
# • ap-northeast-2: ** ami-0fd8c177d3ecba04c **
# • ap-south-1: ** ami-0a344dd53b778620c **
# • ap-southeast-1: ** ami-0d80989bcb13d1bce **
# • ap-southeast-2: ** ami-06903abea3783153c **
# • ca-central-1: ** ami-08d1f037c52e6e9d3 **
# • cn-north-1: ** ami-0668616df95243a8a **
# • eu-central-1: ** ami-067d2d0138289699b **
# • eu-north-1: ** ami-0a83889fedd0337d0 **
# • eu-west-1: ** ami-09cb5c3afd306d225 **
# • eu-west-2: ** ami-0b440d77860532ea9 **
# • eu-west-3: ** ami-07580e5294981f9f5 **
# • sa-east-1: ** ami-08ecccab4d47f9c6f **
# • us-east-1: ** ami-0a04525bbfcc428eb **
# • us-east-2: ** ami-02b7c720c472de2c1 **
# • us-gov-east-1: ** ami-0ba193c5b36ad20b7 **
# • us-gov-west-1: ** ami-09746cb84a25cbb6c **
# • us-west-1: ** ami-0be43279f3b25abe6 **
# • us-west-2: ** ami-0b144cc3a255c0d5e **
