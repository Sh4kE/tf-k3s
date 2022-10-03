WORKSPACE=$(terraform workspace show)

terraform destroy --var-file=$(terraform workspace show).tfvars --refresh=false -auto-approve\
    -target=module.dns \
    -target=module.server1 \
    -target='module.servers[0]' \
    -target='module.servers[1]' \
    -target='module.agents[0]' \
    -target='module.agents[1]'

terraform apply --var-file=${WORKSPACE}.tfvars -auto-approve \
    -target=module.secgroup \
    -target=module.network \
    -target=module.load-balancer \
    -target=module.floating-ip-master-lb \
    -target=module.server1 \
    -target='module.servers[0]' \
    -target='module.servers[1]' \
    -target='module.agents[0]' \
    -target='module.agents[1]' \
    -target=module.dns \
    -target=data.k8sbootstrap_auth.auth

cp -f ~/.kube/config ~/.kube/config.bak

export CA_CRT=$(terraform output -raw ca_crt | base64 | tr -d "\n")
export K3S_EXTERNAL_URL=$(terraform output -raw k3s_external_url)
export TOKEN=$(terraform output -raw token)

yq -i "(.clusters[] | select(.name == \"${WORKSPACE}\")) = { \"cluster\": { \"certificate-authority-data\": \"${CA_CRT}\", \"server\": \"${K3S_EXTERNAL_URL}\" }, \"name\": \"${WORKSPACE}\" }" ~/.kube/config
yq -i "(.users[] | select(.name == \"${WORKSPACE}\")) = { \"user\": { \"token\": \"${TOKEN}\" }, \"name\": \"${WORKSPACE}\" }" ~/.kube/config

terraform apply --var-file=${WORKSPACE}.tfvars -auto-approve \
    -target=module.k8s-helm-charts

terraform apply --var-file=${WORKSPACE}.tfvars -auto-approve \
    -target=module.k8s-apps.data.kubernetes_secret.argocd-initial-admin-secret \

terraform apply --var-file=${WORKSPACE}.tfvars -auto-approve \
    -target=module.k8s-apps.kubernetes_manifest.openstack-cinder-csi-argocd-application \
    -target=module.k8s-apps.kubernetes_manifest.vault-argocd-application

kubectl exec vault-0 -- vault operator init -key-shares=5 -key-threshold=3 -format=json > cluster-keys.${WORKSPACE}.json

# UNSEAL_TOKEN_0=$(jq -r ".unseal_keys_b64[0]" cluster-keys.${WORKSPACE}.json)
# UNSEAL_TOKEN_1=$(jq -r ".unseal_keys_b64[1]" cluster-keys.${WORKSPACE}.json)
# UNSEAL_TOKEN_2=$(jq -r ".unseal_keys_b64[2]" cluster-keys.${WORKSPACE}.json)
# UNSEAL_TOKEN_3=$(jq -r ".unseal_keys_b64[3]" cluster-keys.${WORKSPACE}.json)
# UNSEAL_TOKEN_4=$(jq -r ".unseal_keys_b64[4]" cluster-keys.${WORKSPACE}.json)
#
# ROOT_TOKEN=$(jq -r ".root_token" cluster-keys.${WORKSPACE}.json)
# echo ${ROOT_TOKEN} > ~/.vault-token.${WORKSPACE}
#
# kubectl exec vault-0 -- vault operator unseal $UNSEAL_TOKEN_0
# kubectl exec vault-0 -- vault operator unseal $UNSEAL_TOKEN_1
# kubectl exec vault-0 -- vault operator unseal $UNSEAL_TOKEN_2
#
# kubectl exec -ti vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
# kubectl exec -ti vault-1 -- vault operator unseal $UNSEAL_TOKEN_0
# kubectl exec -ti vault-1 -- vault operator unseal $UNSEAL_TOKEN_1
# kubectl exec -ti vault-1 -- vault operator unseal $UNSEAL_TOKEN_2
#
# kubectl exec -ti vault-2 -- vault operator raft join http://vault-0.vault-internal:8200
# kubectl exec -ti vault-2 -- vault operator unseal $UNSEAL_TOKEN_0
# kubectl exec -ti vault-2 -- vault operator unseal $UNSEAL_TOKEN_1
# kubectl exec -ti vault-2 -- vault operator unseal $UNSEAL_TOKEN_2

