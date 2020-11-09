## STEP 1: Build & Test the REACT APP

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

In the project directory, you can run:

### `yarn start`

Runs the app in the development mode.<br />
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.<br />
You will also see any lint errors in the console.

### `yarn test`

Launches the test runner in the interactive watch mode.<br />
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `yarn build`

Builds the app for production to the `build` folder.<br />
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.<br />
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `yarn eject`

**Note: this is a one-way operation. Once you `eject`, you can’t go back!**

If you aren’t satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you’re on your own.

You don’t have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn’t feel obligated to use this feature. However we understand that this tool wouldn’t be useful if you couldn’t customize it when you are ready for it.

### Learn More: 

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).

### Code Splitting

This section has moved here: https://facebook.github.io/create-react-app/docs/code-splitting

### Analyzing the Bundle Size

This section has moved here: https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size

### Making a Progressive Web App

This section has moved here: https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app

### Advanced Configuration

This section has moved here: https://facebook.github.io/create-react-app/docs/advanced-configuration

### Deployment

This section has moved here: https://facebook.github.io/create-react-app/docs/deployment

### `yarn build` fails to minify

This section has moved here: https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify

## STEP 2: Containerization of the REACT APP using Docker 

This project has Containerization support using Docker: 

Note: you need to have Docker running locally for the commands to work. 

To get started with Docker: https://www.docker.com/get-started

In the project directory where the Dockerfile is located, you can run following to build a container with a nginx web server:
### `docker build -t react-docker-k8s-helm .`

This will create an image with the react app running in an nginx web server. 

Now, we can run a container based on this image:
### `docker run -it -p 3000:80 --rm react-docker-k8s-helm:latest`

We can ignore the warnings in the console: 10-listen-on-ipv6-by-default.sh: error: /etc/nginx/conf.d/default.conf is not a file or does not exist (this is because we have modified that to make our react router work - you can verify that in nginx/nginx.conf file).  Since we are pointing our local port 3000 to container port 80, we can open the react app by browsing to http://localhost:3000 

We have a react app running as a docker container! 

In our terminal, we should see HTTP traffic from our browser to our container.  Before we conclude the docker part, one important concept to understand is the difference  between a Docker image and a Docker container.  Metaphorically, an image is a recipe whereas container is the cake. So just like you can make many cakes using the same recipe, you can have many running containers of the same image. 

Finally, lets push the docker container image to our public docker hub repository. 

First, lets tag our image: 
### `docker tag react-docker-k8s-helm [your public docker hub repository name]/react-docker-k8s-helm`

Then push it a docker hub: 
### `docker push [your public docker hub repository name]/react-docker-k8s`

Note that, by default Kubernetes looks in the public Docker registry to find images. If your image doesn't exist there it won't be able to pull it. We can also use our local or a private image repository but for simplicity we will just use a public docker hub image repository.

## STEP 3: Container Orchestration using Kubernetes 

This project has a reference yml file that can be use to deploy the Docker contaioners (from STEP 2) in Kubernetes.

In part 2, we have launched a single container using the image we have created for our simple react app. That is fine for our local/development environment but how would we manage the containers for production workloads? If required, how will we scale our react app image into thousands of containers? Enter Kubernetes. Kubernetes in essence is a Container Orchestration Platform. 

You need to have Docker and Kubernetes running locally for this part. 
There are various option to deploy to Kubernetes (all major public cloud provider has Kubernetes engine where you can deploy). However, one simple option is using the Kubernetes engine that comes with Docker (you need to enable it from Docker Desktop if you have not already) and that’s what we will be using here: 
https://www.docker.com/products/kubernetes 

Now, in the root of your project, verify a file name deployment.yml and contents of it. 
Few things to note about the deployment.yml file:

- Metadata and labels can be anything but if you are building a full stack applications then it is important to note as Kubernetes uses these metadata to puts applications together. 

- We are creating 2 container (replicas) from our image. 

- For image, we are using the image we have created and pushed to our docker hub in Part 2.

- We are opening Port 80 of our container to outside world. Port 80 is a common industry practice to open up for web traffic and if you review the nginx/nginx.conf file in our repo you will see that we are listening to Port 80. 

- You can use the resources as specific here for POC purpose but if you are using this for production you may like to to review this.

- Finally, livenessProbe and readinessProbe arevpart of Kubernetes auto healing  mechanism and one of many reasons that makes Kubernetes a great container orchestration tool. Kubernetes uses liveness probes to know when to restart a container. Whereas readinessProbe allows applications to have extra time to get ready to be added to the cluster i.e. an application might need to load large data or configuration files during startup, or depend on external services after startup. 

Please read more about the deployment file here:

https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

Now, we can use this deployment file with the Kubernetes CLI (kubectl) to deploy our Containers into a Kubernares cluster. 
(Note: you can deploy as pods as well but deployment is a preferred approach)
### `kubectl apply -f deployment.yml`

Verify the deployment was successful 
### `kubectl get deployment`
We should see the app we have deployed. 

Verify the pods with react app container images are running:
### `kubectl get pods`

Verify a pod with react container is configured & deployed correctly:
### `kubectl describe pod react-docker-k8s-xxxxxxxxxx-xxxxx`

You can also ssh into the container pod to verify the react app contents:
### `kubectl exec react-docker-k8s-xxxxxxxxxx-xxxxx -it sh`
Navigate to /usr/share/nginx/html folder where we should see the contents from build folder of our react app (from STEP 1). 

Verify the REACT app is working correctly: (Note: here we are simply binding a port from our local machine port 8080 to container port 80)
### `kubectl port-forward deployment/react-docker-k8s 8080:80`

Open http://localhost:8080 to view the React app in the browser.
You can exit the terminal once done.

You can also use port forward on the PODS as well.
### `kubectl port-forward pod/react-docker-k8s-xxxxxxxxxx-xxxxx 8080:80`

Now, lets try out the autohealing feature of Kubernetes. 
Lets elete one of the pod from our cluster (out of 2 we have created using our deployment.yml file): 
### `kubectl delete pod/react-docker-k8s-xxxxxxxxxx-xxxxx`

Now, watch how kuberantes autoheal our cluster and automatically build a POD to replace the delelted POD! 
### `kubectl get deployment --watch`


## STEP 4:  Kubernetes Package Manager Using Helm

You need to have Helm installed locally and Step 1 and Step 2 above completd for this. 

Deploy this as a Kubernates package with the Helm Chart: 
### `helm install react-docker-k8s-helm-chart-v1 ./react-docker-k8s-helm-chart `

Now, you should see a new deployment for react-docker-k8s-helm-chart-v1  when you use:
### `kubectl get deployment`