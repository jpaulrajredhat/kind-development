# Pull the image with the correct architecture
docker pull --platform linux/arm64,linux/amd64 trinodb/trino:467
# Load into kind cluster
kind load docker-image trinodb/trino:467

# If that fails:
docker save osclimate-trino:latest -o trino.tar
docker cp trino.tar kind-test-cluster:/trino.tar
docker exec -it kind-test-cluster sh
ctr --namespace=k8s.io images import /trino.tar
