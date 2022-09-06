CLUSTER=$1

source ~/Dokumente/${CLUSTER}.sh

pushd $(pwd)
cd ~/
ln -sf .vault-token.${CLUSTER} .vault-token
popd

terraform workspace select ${CLUSTER}

kubectl config use-context ${CLUSTER}

