<div align="center">
<img src="https://marketplace.deep-hybrid-datacloud.eu/images/logo-deep.png" alt="logo" width="300"/>
</div>

# DEEP-OC-demo_app

[![Build Status](https://jenkins.indigo-datacloud.eu/buildStatus/icon?job=Pipeline-as-code/DEEP-OC-org/DEEP-OC-demo_app/master)](https://jenkins.indigo-datacloud.eu/job/Pipeline-as-code/job/DEEP-OC-org/job/DEEP-OC-demo_app/job/master)

This is a container that will run [demo_app](https://github.com/deephdc/demo_app) application leveraging the DEEP as a Service API component ([DEEPaaS API V2](https://github.com/indigo-dc/DEEPaaS)).

    
## Running the container

### Directly from Docker Hub
> **Warning**: This is not yet available! For the time being you have to build the Docker manually.

To run the Docker container directly from Docker Hub and start using the API simply run the following command:
```bash
docker run -ti -p 5000:5000 -p 6006:6006  -p 8888:8888 deephdc/deep-oc-demo_app
```

This command will pull the Docker container from the Docker Hub [deephdc](https://hub.docker.com/u/deephdc/) repository and start the default command (`deepaas-run --listen-ip=0.0.0.0`).

**N.B.** For either CPU-based or GPU-based images you can also use [udocker](https://github.com/indigo-dc/udocker).

### Building the container

If you want to build the container directly in your machine (because you want to modify the `Dockerfile` for instance) run the following instructions:
```bash
git clone https://github.com/deephdc/DEEP-OC-demo_app
cd DEEP-OC-demo_app
docker build -t deephdc/deep-oc-demo_app .
docker run -ti -p 5000:5000 -p 6006:6006 -p 8888:8888 deephdc/deep-oc-demo_app
```

These three steps will download the repository from GitHub and will build the Docker container locally on your machine. You can inspect and modify the `Dockerfile` in order to check what is going on. For instance, you can pass the `--debug=True` flag to the `deepaas-run` command, in order to enable the debug mode.


## Connect to the API

Once the container is up and running, browse to `http://localhost:5000` to get the [OpenAPI (Swagger)](https://www.openapis.org/) documentation page.
