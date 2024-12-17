# Kind Cluster:

kind is a tool for running local Kubernetes cluster using Docker container.
kind was primarily designed for testing Kubernetes itself, but can be used for local development.
Kind is ligt weight Kubernetes platform consume less reosuce so that developer can run most of the Data Mesh compoenrts locally and alos it is very close to target kubernetes platform like OpenShift . 

# Prerequisites
    
    1.Docker
    2.Helm

All prerequisties are included in the kind install script. kind install script has been tested with Mac and Linux environment. If any errors are occured during installtion, it could be local environment specific issue that need to addressed based on environment variation. 

# Installation

**Step 1 :** To Install Kind, run the script with the desired action: You need to run this scrit only first time.  If you want to desroy the deployment, there is the scri the cluster. 

    ```bash
    chmod +x install-kind.sh
    ```
   
    ```bash
    ./install-kind.sh install kind

    ```

**Step 2 :** Create a Cluster: You need to run this scrit only first time. 

    ```bash
    ./kind-cluster.sh osclimate-cluster create
    ```
   
   
**Step 3:** if Step 2 completed, verify cluster

    ```bash
    kubectl cluster-info --context osclimate-cluster
    ```
**Step 4 :**  Datamesh components deployment. As of now , this deploymet script supports only Airflow,  Trino and Minio.

    ```bash
    chmod +x deploy.sh
    ```

To deploy **all data mesh** components. Before run deploy script read the notes below.

    ```bash
    ./deploy.sh all
    ```

To deploy just **Airflow**

        ```bash
        ./deploy.sh airflow
        ```

If you need to test your Aifflow dags, copy all dags to "/dafs" folder and build a image locally using release.sh script provided here. To make this chages effect, update environment varibales AIRFLOW_IMAGE="XXXX" and AIRFLOW_TAG="X.X" and execute " ./deploy.sh " with correspoding input parameter based on what are the componets that you want to deploy. 
    
If you make any changes on your exiting dags that need to be deployed , you need to build airflow image locally and update environment varibales AIRFLOW_IMAGE="XXXX" and AIRFLOW_TAG="X.X" to deploy.sh script and then run **deploy.sh airflow** .

To deploy just **Trino**

    ```bash
    ./deploy.sh trino
    ```
To deploy just **Minio**
         
    ```bash
    ./deploy.sh minio
    ```
    
**Note :** Deploy script will deploys specific component's helm chart (Airflow, Trino & Minio ) and import specific component images to kind cluster and deploy the component, once its deployed successfully, forward the port to local host so that you can access localhost on your browser.

**Exxmale :**

    Aiflow : localhost:8080
    Trino  : localhost:8081
    Minio  : localhost:9000

 **Delete** Kind Cluster :

    ```bash
    kind delete cluster --name osclimate-cluster 
    ```

**Destroy** Kind installation

    ```bash
    ./install-kind.sh delete kind
    ```
