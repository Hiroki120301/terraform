#!/bin/bash
set -euo pipefail 

cd ../../examples/hello-world

terraform init
terraform apply -auto-approve

sleep 60

terraform output -json |\
jq -r '.instance_ip_addr.value' |\
xargs -I {} curl http://{}:8080 -m 10

terraform destroy -auto-approve