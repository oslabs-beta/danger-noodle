# Docker

### Basics:
- Image is the file system, including the executables and execution commands.
- Container is the environment of the image executed, partitioned on the general docker VM.
#### Basic Commands:
- Run: starts the container and if do not exists checks the Docker Hub (repo of Docker) and downloads it from there
 and starts.
- Start: If the image is in your local, executes the container and takes a call back, if that call back execution
  exists in the image it self. If called with -a that stands for 'attach', logs the out put automatically.
- Create: Creates a docker container from an image, does not start it.
- Logs: Logs out all the outputs made from that container up until that point.
- Stop: Send a Terminate signal to the container to shut down.  Does clean up
  - If the stop Terminate signal is not executed with in 10 seconds, automatically docker will send a Kill signal.
- Kill: Sends a Kill signal does not do additional work for cleanup, shuts down immediately.
- PS: Shows the running containers in the process.
- --interactive --tty ('-it') these are flags to use with exec command.
  - Interactive starts an stdin
  - TTY chains a teletypewriter to it  
  so that we can reach the terminal of the executed file.
- The call back of any Start or Run process can be 'sh' command that stands for **shell** that would start a shell in
 the container that you can run commands on.

### Creating A Docker File:
![How to Create A Docker File](./creatingADockerFile.png)
#### Creating An Image:
![creating an image](imagecreating.png)
#### Creating an Image Anology:
![dockerasOS](dockerasOS.png)
#### Rubilds Caching
- Docker caches the build a cash from the latest build, as long as you do not change the order of the docker commands
 in your docker file, it would run the build from its cache and that makes docker very performant.
#### Naming Convention of Builds
![namingconvention](namingconvention.png)
- community images do not follow this convention.
##### Image Tagging
``docker build -t armangurkan/redis:latest . //-t for tag and "." for path``

##### How to Create an Image Manually instead of Using A Dockerfile:
###### Example: Manually Creating the Redis Image in the terminal
1. ``docker run -it alpine sh //docker istance is ran for alpine``
2. ``apk add --update redis //inside alpine shell command to download redis``
3. manually exit from alpine execution.
4. get the id of the alpine container by ``docker ps``
5. ``docker commit -c 'CMD ["redis-server"]' {#IdofAlpineContainer} //-c flag is for default command and after the
 flag the command is defined``
6. get the id of the new redis-server docker id ``docker run -it <#IdofRedisDocker>``  
This example shows the same functionality of dockerfile of this:
```
/*Dockerfile*/
FROM alpine  
RUN apk add --update redis
CMD ['redis-server']
```

#### Creating Containers from Your Own Projects
![customimage](custompage.png)
![copysyntax](copysyntax.png)
_** First ./ is for the current directory PATH, the second ./ is the container PATH**_
1. Express mini project created under [simpleweb](./simpleweb).
2. Dockerfile created.
    ```
    FROM node:alpine
    WORKDIR /usr/app
    COPY ./package.json ./
    RUN npm install
    COPY ./ ./
    CMD ["npm", "start"] #make sure to use double quotes
    ```
3. ``Docker build .`` the image is built
4. ``Docker build -t armangurkan/simpleweb .`` latest is appended if not entered. rebuild
5. ``Docker run armangurkan/simpleweb``
6. Port mapping is made within the run command
    ![routemapping](routemapping.png)
    ``docker run -p 8080:8080 armangurkan/simpleweb //two ports do not have to be identical``

###Running Multiple Docker Containers
####Docker Compose Commands
- `docker-compose up -d` d flag is for detach.
- `docker-compose down` stops all the running containers.
- Also docker-compose.yml file should be constructed, pls [visit docker-compose.yml](visits/docker-compose.yml)
#### Docker docker-compose.yml Configuration:
- Server names, ports, images, if no images build paths, and restart policies etc. can be defined.
##### Restart Policies:
![composeymlrestartoptions](composeymlrestartoptions.png)
##### Container Status Check:
- `docker-compose ps` same thing as `docker ps`
    - major difference is `docker-compose ps` has to be ran on the same directory as the docker-compose.yml file
    , `docker ps` does not.
### Deploying to Production
It actually requires a workflow as a best practice:
![dockerworkflow](dockerworkflow.png)
#### Setting Up Dockerfiles:
- We should have two Dockerfiles, one for development and one for production.
    - Dockerfile.dev
        ````
      FROM node:alpine
      WORKDIR '/app'
      COPY ./package.json ./
      RUN npm install
      COPY ./ ./
      CMD ["npm", "run", "start"]
      ````
      - To run this command and specify that our dev environment Dockerfile is Dockerfile.dev we run this following
       command:
       ``docker build -f Dockerfile.dev .``
       - You have to delete your node modules directory in the local environment because those dependencies will be
        placed in the docker container where you are going to test your code.

    - [Dockerfile (production Docker file)](#creating-a-production-container)

#### HotStartReload on Docker Containers<a name="dockervolume"></a>
- After `Docker run` command we bind the local files to the container with `-v` flag and create references to the
 directories in the container to the directories in the local machine.  `-v` flag stands for Docker Volumes.
  - Docker volumes are kind of file system entities that mirror local files.
  - The docker cli command and docker-compose file config does the same job for hot restart:
  ![dockervolume](dockervolumecommand.png)
  ![dockercomposeVol](dockercompose.png)

#### Running Tests On Docker Container
- tests can be run via the command declared in the package.json if it is a react project for example.
    - For example
    - After running ``docker-compose up -d``
    - We can run ``docker exec -it <container-tag-name> npm run test``

### Creating a Production Container
- The production environment does not include our Dev Server.
- The production environment requires another production server (ex: nginx);
- We will have to create another Dockerfile for our build we take for the production environment.
    ![productionDockerfileFlow](productionDockerfile.png)

- The containerization of the production version is going to have 2 phases,
    ![breakdownFlowDeployment](detailedDeployFlow.png)
    - The build phase:
        - This is where all the dependencies are downloaded and bundled by npm run build command.
    - The run phase:
        - The run phase takes the output of the build phase as a parameter by copying it, and all the other memory
         created in the execution context of the build command is going to be deleted as that execution context closes.
    - The Dockerfile :
        ````
        # as builder command indicates that this is going to be the build phase
        FROM node:alpine as builder
        WORKDIR '/app'
        COPY ./package.json ./
        RUN npm install
        COPY ./ ./
        RUN ["npm", "run", "build"]
      
        # another from statement indicates the new phase 
        FROM nginx
        # for actual server to start receiving 80
        EXPOSE 80
        COPY --from=builder /app/build /usr/share/nginx/html
        # we don't have to have CMD statement as a return statement since the nginx image created has a self starter
        # process
        ````
    - `docker build .` builds it.
    - The next command to start the prod container would be `docker run -p 8080:80 <image_tag_name or image_id>` the
     reason we route it port 80 is that 80 is the default http port on the servers.

##Deployment
###Continuous Integration with Travis
- Travis workflow:
    ![travisworkflow](travisworkflow.png)

    - The reason we use docker file to use Dockerfile.dev is the fact that Travis is going to run the test suit and
     test suit is going to be testing the un-built and bundled version of the code, the reason for that is after
      bundling the variable decelerations and other part of the code may be changed for the compression effectiveness.
    - The travis directives are going to be defined in the `.travis.yml` file.  That file would look like:
    ```
  #all the travis commands would require super user permissions to be executed.  
  sudo: required 
    services:
          # declare docker usage
        - docker 
    before_install:
          # the tagname defined after -t can be anyting best practice is to name it dockerusername/repoName
        - docker build -t armangurkan1/myProject -f Dockerfile.dev .
    script:
      - docker run -e CI=true armangurkan1/myProject npm run test
    deploy:
        edge: true
        # already defined in Travis CI
        provider: elasticbeanstalk
        region: "us-west-2"
        app: "myProject"
        env: "MyProject-env"
        #when you get elasticbeanstalk you get S3 bucket automatically, find it
        bucket_name: "elasticbeanstalk-us-west-2-93483498439"
        bucket_path: "myProject"
        on:
            branch: master
        access_key_id: $AWS_ACCESS_KEY
        secret_access_key:
            secure: "$AWS_SECRET_KEY"
    ```


###Deploying to AWS
- Host as AWS
    - Has a load balancer built in.
    - If the traffic increases, the elastic beanstalk will replicate our traffic.
    ![ElasticBeanStalkStructure](AWSenv.png)
- The easiest way to start is Elastic Beanstalk for single containers.
    - Base configuration is going to Docker.
- User should be created for each program to define credentials.  Travis is going to be the user.
    - Select Programmatic access only.
    - For policies we are going to select one of the defined policies
    - We can select full access for elasticbeanstalk
    - Get access keys and access secret.
    - Go to TravisCI and create envSecret
        - A key for aws_access_key
        - A secret ofr aws_access_secret.


access_key_id: $AWS_ACCESS_KEY  
secret_access_key: $AWS_SECRET_KEY

## Deploying Multiple Containers
This is the app structure of the app to be created:
![complexappStructure](complexappstructure.png)

### Creating Dockerfile.dev Files for Each Service
- Unless we are using nodemon to hsr we have to run npm run start, in the Dockerfile.dev, or npm run dev, it is
 because of the simple fact that 'dev' is the script we mapped in the package.json file.
- The containers know how that they should be in connection via the way we set up our docker-compose.yml file.  The
 docker-compose.yml file will be in the root directory of the project.
  - You also have to require their node agents as npm packages to handle the communication between these different
   containers.  Just as if we are requiring for example 'mongoose' in an express app; **but we don't make a
   connection to it** as we do in Mongo Atlas, since it is not a cloud service and connection is handled by **Docker
   Server**.  Please remember that Docker is an ecosystem, not a single piece of software.  For details please visit
   complexApp directory.
### Deployment of MultiContainer Projects
![multicontainerdeployflow](multicontainerdeployflow.png)

<https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions>
- To connect different services within AWS, you have to do it in security group settings in AWS menu and enable any
 request to be received within my VPC (virtual private cloud).  It can be too but it can't be as a different
  container in elastic beanstalk.
- Storage services are excluded from the main VPC instance
    - Each storage service should served from either RDS or Cache services within AWS.
# KUBERNETES
- Pods run containers
- Services are in charge of networking
- ApiVersion in the yaml file dictates what kind of object you want to create in kubernetes cluster
    - Those objects can be:
        - Pods
        - Services
        -  Event etc...
        - Nodes are VMs
### Kubernetes Hierarcy
![kuberneteshierarchy](kuberneteshierarchy.png)
- We would only use a pod with multiple containers if the containers functionality is very very tightly coupled
  ![podstructure](podstructure.png)
- Relationship between pods and services are as follows: ![servicesandpods](servicesandpods.png)
- Nodeport service functionality is as follows (a communication layer): ![nodeport](nodeport.png)
  ![detailednodeport](detailednodeport.png)
- Services and Pods do communicate with the decleration made in the config files, by label <=> selector keys.
- Port mapping diagram is as follows: ![portmapping](routing.png)
### Connecting Running Containers
- We use `kubectl apply -f <filename>` to create pods.
- We use `kubectl get pods` for listing them.
### Entire Deployment Flow for Kubernetes
![deploymentworkflow](deploymentworkflow.png)
- Deployment files are the yaml files to set Pods and other Service objects.
- Each node will get the multi-worker containers from Docker Hub.
    - It takes an image per Node.
    - And it initializes four containers, as directed in deployment files out of those images.
- If you kill one container, since it was directed to run 4 containers, it will automatically restart another one, to match 4.
- `kubectl` only reaches the master.
- Key takeaways: ![keytakeaways](importantnotesonkubernetes.png)
- Kubernetes deployment strategies: ![kubernetesdeploymenttypes](kubernetesdeploymenttypes.png)
- Imperative Deployment Example (manually running the commands and structure kubernetes): ![imperativedeployment](imperativedeployment.png)
- Declerative Deployment Example (make kubernetes master maintain the structure by the yaml files given): ![declerativedeployment](declerativedeploymentonkubernetes.png)
##### Comparison Declarative Imperative
![decvsimp](declerativevsimperative.png)

## Maintaining a Kubernetes Environment
### Updating Existing Objects
- If the **pod name** and **kind** are the same for a pod, updating a config file and feeding it to the master updates the pod rather than making a new one ![updatingpods](updatingpods.png)
- If the name is new it will create a new pod.
- If the image name is changed form multi-client to multi-worker in [client-pod.yaml](./kubernetes/client-pod.yaml).
- To get detailed information about an object we run `kubectl describe <object type> <object name>` command.
### Limitations in Config Updates
- We are only aloud to update image related information within the container while kubernetes is running. Directly besides the code in the pod which is the image.
- This is our direct mutability to a Pod Object: ![podimmutability.png](podimmutability.png)
- Deployments are the objects we utilize to edit the Pod Objects.  Deployments in Kubernetes are **Objects**
> **Pods:** Runs one or more closely related containers  
> **Services:** Sets up networking in a Kubernetes Cluster  
> **Deployment:** Maintains a set of identical pods, ensuring that they have the correct config and that the right number exists
- This is the difference between Pods and Deployments: ![podsvsdeployments](podsvsdeployments.png)
- How are **pods** and **deployments** relate to each other: ![poddeploymentrelation](pod_deployment_relation.png)
- How **pods** and **deployments** find each other via component and label tags: ![howdeploymentreachpod](howdeploymentreachpod.png)
## Applying a Deployment
- Before we start creating pods via deployments we would like to delete manually created pods (usually), and this is the command: `kubectl delete -f <configfileofPod>`
    - This deletion is an imperative command.
- To create a new pod with Deployment Object: `kubectl apply -f <client-deployment.yaml`.
- This is the structure of communication after creating a Pod Object using a Deployment Object. ![communicationoutlinepods](communicationoutlinepods.png)
- To get detailed info about pods: `kubectl get pods -o wide`, we can see the IP Address of the pod assigned by Kubernetes Env.
### Scaling and Changing Deployments
- You can do it by changing the deployment yaml file, if you change the `replicas` value, the number of running **pods** are going to be changed.
### Updating and Rebuilding Images
#### Triggering Deployment Updates and Imperative Strategies
- These are the steps we are going to follow: ![UpdatingImagesForRunningPods](UpdatingImagesForRunningPods.png)
    1. First we go to the source code and change the code.
    2. Then we take another image by running `docker run build <username>/<servicename>:v1 .` command. Version number is randomly given it can be anything. **Remember images are not being created by Kubernetes, it is created by Docker.**
    3. Then, we upload it to **Docker Hub** `docker push <username>/<servicename>:v1` **Remember Kubernetes is feeded the Images by Docker Hub**
    4. Then, we update image property of the client-deployment.yaml `kubectl set image deployment/client-deployment client=stephengrider/multi-client:v1`
        1. So, it is: `kubectl set image deployment/<filename> <conatinerName>=<imagename {username/imageName}>:<version>`

### Multiple Docker Installations and Reconfiguring Docker CLI
Here is a review of how the Kubernetes Uploading (specificly used that term so you do not mix a deployment with Deployment Object):
![kubernetesflowrevisit](kubernetesflowrevisit.png)
![#reviewkubernetesdepflow](reviewkubernetesdepflow.png)<a name='reviewkubernetesdepflow'></a>
- There are two Docker Servers running one for local computer, one in Kubernetes Node (Virtual Machine).
- Our docker-client in our local machine can be configured to either communicate with the Docker Server in the Virtual Machine and/or my local machine.
- The docker-client in the VM is only reserved for taking orders from Kubernetes Master through **kubectl**.
- if you are using **minikube** the command to reconfigure your local docker-client to talk to Docker Server in the Kubernetes VM is: `eval $(minikube docker-env)`
    - This would only applicable for the terminal instance as long as that terminal session.
-  

## Multi Container App with Kubernetes
This is going to be the structrue:
![complexappwithkubernetes](complexappwithkubernetes.png)
##### Steps:
1. Create config files for each service and deployment
2. Test locally
3. Create a Github/Travis flow to build images and deploy
4. Deploy app to a cloud provider.
#### ClusterIP Object
- Cluster IP Object is only to be used from Deployment Objects to reach other Deployment Objects ![clusterIp](clusterIP.png)
- We are going to create a yaml file for every single Service Object and Deployment Object that is shown above in [multi container structure](#reviewkubernetesdepflow)
    - You can actually make one file, but everything we write to different yaml files have to be seperated by `---` but it would be really messy.
#### Persistent Volume Claim for Postgres
- Volume refers to the Object that enables to share the filesystem of the host and the container vm; kind of a reference to the filesystem of the host. (See: [docker volumes](#dockervolume))
- Current Situation of the PostGres Structure:  The reason we need a postgres container is that if the Deployment crashes **we would loose all the db**.
    ![postgresDeploy_postgresVolume](postgresDeploy_postgresVolume.png)
- When we point a reference to the volume, it would reference the same volume when a new one is started.
- <strong>Very important to know that the number of DB Deployments can only be one because they would be reaching the same database, or else they would collide.  If we want to increase DB Container availability we need to do much more advanced configurations such as PVCs sharded with sharded DBs </strong>
#### Detailed Look On Volumes
##### Kubernetes Volumes
- Kubernetes Volumes are Objects, so in this case the __Volume__ we are referring to are not a generic volume, but a __Persistent Volume Claim__ and a __Persistent Volume__ .
![volume](volumedefinition.png)
- On the other hand the the __Kubernetes Volume Object__ Structure can be seen below. This object type is not suitable for hosting DBs but instantiate db information on the Pod Level.
    ![volumeobject](volumeobject.png)
#### Persistent Volume Claim & Persistent Volume
   ![volume_vs_pv](volume_vs_pv.png)
##### Persistent Volume vs Persistent Volume Claim
[BEST EXAMPLE WATCH THIS](https://www.udemy.com/course/docker-and-kubernetes-the-complete-guide/learn/lecture/11582334?start=64#bookmarks)
- Persistent Volume
    : This is the actual hard drive that will be made available on a __Persistent Volume Claim__.
- Persistent Volume Claim
    : Are the list of options you can claim of __Persistent Volumes__.
    If the volume is created on a request it would be called __Dynamically Created Persistent Volume__, if it was a PV that was explicitly created before it is called __Statically Created Persistent Volume__.
##### Access Modes
We have defined a new parameter in the `database-persistent-volume-claim.yaml` __Access Modes__ (`accessModes: - ReadWriteOnce`).  Please refer to the definitions of the value:
![readwriteonce](readwriteonce.png)
##### Creation and Allocation of Persistent Volumes
- When a claim is made to Kubernetes for a __Peristent Volume__ via the __Persistent Volume Object__ ([Please refer to the file](./complex/k8s/database-persistent-volume-claim.yaml)) yaml file Kubernetes allocates a portion of the available hard-drive to itself.
##### Defining Environment Variables
- Current environtment:
  ![environmentk8s](environmentk8s.png)
- The Environment Variables:
    - Redis Host: is going to be the URL Path that __multi-worker__ reaches via a http
    - Redis Port: the port that worker and server communicate with Redis, it is default 6379
    - PGUSER: it is the username to authenticate postgres with
    - PGHOST: it is the Service Name we defined in the yaml
    - PGDATABASE: name of the database, which is postgres
    - PGPORT: the port we get connect to PG Deployment object, the default port is 5432
    - PGPASSWORD: the password to our postgres service we are going to define it at a different entity.
##### Secret Environment Variables As an Object
- Secret Object is created manually in every environment that the code is hosted.
- Creating a __Secret Object__ is done like this: `kubectl create secret generic <secret_name> --from-literal key=value` or `kubectl create secret tls <secret_name> --from-literal key=value`
    - `create`: is the imperative command
    - `generic`: is the type of secret it can be `tls` or `docker-registry`
    - `<secret_name>`: refers to the name of the secret as it is labelled or named in the Pod config file
    - `--from-literal`: refers to the fact that we are going to add the secret information to the imperative command rather than a file.
    - `key=value`: is the key and value of the secret. Ex:`PGPASSWORD=12345`
- Since our images in Docker Hub, we do not need a docker-registry secret, we only need it if we are trying to get images from a docker-registry that is private.
- We will be needing the TLS secret when we are configuring the traffic handling.
#### Load Balancer Service Object Subset of Service Object:
- Loadbalancer is the old way to handle traffic.
    - Create a Load Balancer
    - Send traffic to only one specific Deployment Object ONLY.
    - Load Balancer also directs the cloud provider to initiate a load balancer itself.
- Ingress is the new way to handle traffic.

## HANDLING TRAFFIC WITH INGRESS
> Very important Note:  
>   The Ingress server we are using is github/com/kubernetes/ingress-nginx in KUBERNETES REPO  
>   There is another Ingress Server called github.com/nginxinc/kubernetes-ingress in NGINX INC REPO  
> THEY ARE DIFFERENT PRODUCTS

#### Behind the Scenes in Ingress Server
- This how we do things up until now:
    ![currentstates.png](currentstates.png)
- And the same logic and flow will be valid for Ingress Controller as well:
    ![ingresscontrollerflow](ingresscontrollerflow.png)
- In a detailed view:
    - We are going to create an __Ingress Config__
    - And that config file is going to create an Ingress Controller
    - The Ingress Controller is going to be in charge of creating the entities that routes our traffic to Deployment Objects.
    ![ingresscontrollerstruct](ingresscontrollerstruct.png)
    - But in this project we are going to use the Nginx Ingress which will work like this for simplicity reasons:
    ![projectingress](projectingress.png)
    - Also in our Deployment we are going to use GCloud and the project structure is going to look like this:
    ![gloudingress](gloudingress.png)
- The reason we do not manually create a Load Balancer Object and Create A Ingress Controller Object is the fact that, there are many additional features for Ingress Servers do automatically rather than simple load balancing:
    - A good example to that could be, achieving sticky sessions: which means user should be sending requests to same pod in a deployment object so that it interacts the state that it creates.
- Ingress Controller should be added, NGNIX Ingress added from github/kubernetes.
- Also, we created an ingress-service.yaml file but the kind of the object to be created by the yaml file is AN INGRESS, that creates ingress servers via ingress controller.
