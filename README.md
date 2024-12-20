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
    chmod +x kind-cluster.sh
    ```

    ```bash
    ./kind-cluster.sh osclimate-cluster create
    ```
   
   
**Step 3:** if Step 2 completed, verify cluster

    ```bash
    kubectl cluster-info --context osclimate-cluster
    ```
**Step 4 :**  Datamesh components deployment. As of now , this deploymet script tested and supports only Airflow. Trino and Minio components are included but not tested completelty , will be supported later . 

To deploy just **Airflow**

    ```bash
    chmod +x deploy.sh airflow

    ```
To check airflow pods successfully completed . run the following kubectl command 

    ```bash
    kubectl  get pods -n airflow
    ```

You should see all pod status running as shown below . Airflow deploy script deploys airflow and postgres database and creates required kubernetes manifest and forward POD port to local port 8080 so that airflow web can be accessed by localhost:8080.

    NAME                        READY   STATUS    RESTARTS   AGE
    airflow-7d9598446c-dzntc    2/2     Running   0          9m59s
    postgres-5499cbdffb-47czt   1/1     Running   0          9m59s

Once deployment completed successfuly, Airflow can access from web UI : http://localhost:8080

User id     - admin
password    - airflow123


If you need to test your Airflow dags, copy all dags to "/dags" folder and re-run "./deploy.sh airflow" 
    or 

you can directly copy dags folder to the running POD using the following Kube CLI so that you don't need to re-deploy Airflow. 

There is an another option that you can mount a dag folder to KIND cluster so that all dags will be available immediately without any other external action which is currently in progress.

    ```bash
    kubectl  get pods -n airflow
    ```
    ```bash
    kubectl cp $CURRENT_DIR/dags airflow/$POD_NAME:/opt/airflow/
    ```

**Note** some time port forward script may not be successfull due to pod slow start , in that case run port forward cli explicitly shown below.

Verify that airflow pod and services are running using the following CLI before portward. 

    ```bash
    kubectl  get pods -n airflow
    kubectl  get svc -n airflow
    ```
and then run the following CLI using service or pod to forward pod / service port 8080 to local port 8080

     ```bash
        kubectl port-forward svc/airflow-webserver 8080:8080 -n airflow
    ```

To deploy just **Minio**

        ```bash
        ./deploy.sh minio
        ```

 **Delete** Kind Cluster : 
  
  Note : osclimate-cluste is cluster name.

    ```bash
    kind delete cluster --name osclimate-cluster 
    ```
    or 

    ```bash
    ./kind-cluster.sh osclimate-cluster delete 
    ```


**Destroy** Kind installation

    ```bash
    ./install-kind.sh delete kind
    ```