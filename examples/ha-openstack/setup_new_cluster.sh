#terraform destroy --var-file=$(terraform workspace show).tfvars \
#    -target=module.server1 \
#    -target='module.servers[0]' \
#    -target='module.servers[1]' \
#    -target='module.agents[0]' \
#    -target='module.agents[1]'

terraform apply --var-file=$(terraform workspace show).tfvars \
    -target=module.secgroup \
    -target=module.load-balancer \
    -target=module.floating-ip-master-lb \
    -target=module.server1 \
    -target='module.servers[0]' \
    -target='module.servers[1]' \
    -target='module.agents[0]' \
    -target='module.agents[1]' \
    -target=module.d

terraform apply --var-file=$(terraform workspace show).tfvars \
    -target=module.server1 \
    -target='module.servers[0]' \
    -target='module.servers[1]' \
    -target='module.agents[0]' \
    -target='module.agents[1]' \
    -target=module.load-balancer \
    -target=module.dns \
    -target=module.k8s-helm-charts\
    -target=module.secgroup \
    -target=module.floating-ip-master-lb


