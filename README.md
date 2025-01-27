# Kind Cluster:

kind is a tool for running local Kubernetes cluster using Docker container.
kind was primarily designed for testing Kubernetes itself, but can be used for local development.
Kind is ligt weight Kubernetes platform consume less reosuce so that developer can run most of the Data Mesh compoenrts locally and alos it is very close to target kubernetes platform like OpenShift . 

# Prerequisites
    
    1.Docker
    2.Helm

All prerequisties are included in the kind install script. kind install script has been tested with Mac and Linux environment. If any errors are occured during installtion, it could be local environment specific issue that need to addressed based on environment variation. 

# Installation

**Step 1 :** To Install Kind, run the script with the desired action: You need to run this scrit only first time.  If you want to destroy the deployment, follow the instruction at the bottom of this README file. 

# Install Kind , helm and Docker

```bash
chmod +x install-kind.sh
```
# Install only Kind
   
```bash
./install-kind.sh install kind

 ```

**Step 2 :** Create a Cluster: You need to run this scrit only first time. 

Note : Modify the host path and airflow dags folder specific to your enviroment in **kind-cluster.sh** 
kind-config.yaml will be generated dynamically whe you run kind-cluster.sh.

- hostPath: <home>/kind-development/dags   # Replace with your local directory
        containerPath: /dags  # Path inside the Kind container

```bash
chmod +x kind-cluster.sh
```

```bash
./kind-cluster.sh osclimate-cluster create
```
   
**Step 3:** if Step 2 completed, verify cluster

```bash
kubectl cluster-info --context kind-osclimate-cluster
 ```
**Step 4 :Datamesh components deployment.** Before start deploying, make sure that all datamesh (Airflow , Minio and  Trino ) component images are avaialble in your local machine. **deploy.sh** script will pull Airflow , Trino and minio images from remote repository and stored in local 

**load all datamesh** component images on your local machine to Kind cluster execute **./release.sh** which is required for kind cluster. In order to deploy application to Kind, all images should be available to kind cluster. ./release.sh script load Aiflow , Trino and MinIo images to local machine .

```bash
./release.sh
```

To deploy all datamesh components (Airflow , Trino and Mino) to kind cluster, execute  **./deploy.sh** script.

```bash
chmod +x deploy.sh deploy all
```
Once deployment completed successfuly, all datamesh components can be accessible from the following urls

Airflow : [http:/](http://localhost:8080)
User id     - admin
password    - airflow123

Trino   : [http:/](http://localhost:8081)
User id     - admin


Mino    : [http:/](http://localhost:9005)
User id     - minioAdmin
password    - minio1234

If you find any issue , check all applications are deployed in kind cluster by executing the following 

To check airflow pods successfully completed , run the following kubectl command 

```bash
kubectl  get pods -n osclimate
```
NAME                        READY   STATUS    RESTARTS   AGE
airflow-6d6bc678b6-vjcdr    2/2     Running   0          5m39s
minio-79975bdcc7-f27st      1/1     Running   0          6m52s
postgres-5499cbdffb-knkgm   1/1     Running   0          5m40s
trino-5485b84878-gn6vn      1/1     Running   0          4m52s

**Note:** To run individual components pass component name as a parameter like **deploy.sh all|airflow|trino|minino**

To deploy just **Airflow** , to run all datamesh components pass param "all". To run individual components pass component name as parameter like **deploy.sh deploy "all|airflow|trino|minino"**

```bash
chmod +x deploy.sh deploy airflow
```
To check airflow pods successfully completed . run the following kubectl command 

```bash
kubectl  get pods -n osclimate
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
kubectl  get pods -n osclimate
```
```bash
kubectl cp $CURRENT_DIR/dags airflow/$POD_NAME:/opt/airflow/
```

**Note** some time port forward script may not be successfull due to pod slow start , in that case run port forward cli explicitly shown below.

Verify that airflow pod and services are running using the following CLI before portward. 

```bash
kubectl  get pods -n osclimate
kubectl  get svc -n osclimate
```
and then run the following CLI using service or pod to forward pod / service port 8080 to local port 8080

```bash
kubectl port-forward svc/airflow-webserver 8080:8080 -n osclimate
```

To deploy just **Minio**

```bash
./deploy.sh minio
```

 **Delete** all datamesh component  : 
```bash
./deploy.sh delete all 
```

 **Delete** individual datamesh component  : ./deploy.sh {deploy|delete} {airflow|trino|minio|all}"
 
```bash
./deploy.sh delete airflow 
```

 **Delete** Kind Cluster : 
  
  Note : osclimate-cluste is cluster name.

```bash
./kind-cluster.sh osclimate-cluster delete 
```

**Destroy** Kind installation

```bash
./install-kind.sh delete kind
```
