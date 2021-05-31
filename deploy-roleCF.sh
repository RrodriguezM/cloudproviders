#!/usr/bin/env bash

set -ue

Environment=${1-playground}
Region=${2-us-east-1}
ConfigFile="./params/parameters-${Environment}.json"

get_template_value() {
  cat ${ConfigFile} | jq -r .$1
}

get_parameters() {
  jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|join(" ")' "${ConfigFile}"
}

script_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$script_path"
prefix="role-pipeline-cf"
parameters=$(get_parameters)

echo "Deploying role for cloud formation"
template_name="CreateRoleCF.yaml"

sam_deployed_bucket=artifactcftest

aws cloudformation deploy --template-file ${template_name} \
                          --stack-name ${prefix}-cross-account-role \
                          --s3-bucket $sam_deployed_bucket \
                          --s3-prefix SAM \
                          --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
                          --region $Region \
                          --no-fail-on-empty-changeset \
                          --parameter-overrides $parameters
