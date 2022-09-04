CLUSTER=$1

#if [ "$CLUSTER" = "openstack" ]; then
#    echo "openstack"
#elif [ "$CLUSTER" = "wavestack" ]; then
#    echo "wavestack"
#else
#    echo "$1 is not a supported argument"
#fi

source ~/Dokumente/${CLUSTER}.sh

pushd $(pwd)
cd ~/
ln -sf .vault-token.${CLUSTER} .vault-token
popd

terraform workspace select ${CLUSTER}

kubectl config use-context ${CLUSTER}

