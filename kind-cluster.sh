#!/bin/bash

CLUSTER_NAME=${1:-kind-cluster} # Default cluster name if not provided
ACTION=${2:-create} # Action: create, delete, or status
CONFIG_FILE="kind-config.yaml" # Default Kind config file
CURRENT_DIR=$(pwd)
# Function to create a Kind cluster
create_cluster() {
    echo "Creating Kind cluster: $CLUSTER_NAME..."
    cat <<EOF > $CONFIG_FILE
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

# Enable Ingress:

# nodes:
#   - role: control-plane
#     extraPortMappings:
#       - containerPort: 80
#         hostPort: 8080
#       - containerPort: 443
#         hostPort: 8443

#   - role: worker
#   - role: worker

# nodes:
#   - role: control-plane
#   - role: worker
#   - role: worker


nodes:
  - role: control-plane
    extraMounts:
      - hostPath: $CURRENT_DIR/dags   # Replace with your local directory
        containerPath: /mnt/hostpath  # Path inside the Kind container
  - role: worker
    extraMounts:
      - hostPath: $CURRENT_DIR/dags  # Same local directory
        containerPath: /mnt/hostpath

EOF

    kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"
    echo "Cluster $CLUSTER_NAME created successfully."
    echo "Setting resource limits for Kind containers..."
    docker update --cpus 3 --memory 6g --memory-swap 6g "$CLUSTER_NAME-control-plane"
    docker update --cpus 3 --memory 6g --memory-swap 6g "$CLUSTER_NAME-worker"
  
  echo "Cluster created and resource limits applied."
}

# Function to delete a Kind cluster
delete_cluster() {
    echo "Deleting Kind cluster: $CLUSTER_NAME..."
    kind delete cluster --name "$CLUSTER_NAME"
    echo "Cluster $CLUSTER_NAME deleted successfully."
}

# Function to get cluster status
status_cluster() {
    echo "Fetching status for Kind cluster: $CLUSTER_NAME..."
    kubectl cluster-info --context "kind-$CLUSTER_NAME"
}

# Main logic
case "$ACTION" in
    create)
        create_cluster
        ;;
    delete)
        delete_cluster
        ;;
    status)
        status_cluster
        ;;
    *)
        echo "Usage: $0 <cluster-name> <create|delete|status>"
        exit 1
        ;;
esac
