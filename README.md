# apmmq-docker
Monitoring a queue manager running in a Docker container

# Overview

By using the Dockerfile and scripts that are provided in this repository, you can use IBM Performance Management (http://www-03.ibm.com/software/products/en/application-performance-management) to monitor the IBM MQ Advanced for Developers (http://www-03.ibm.com/software/products/en/ibm-mq-advanced-for-developers) that is running inside a Docker container. 
Any feedback regarding the function that is described in this article will be very much appreciated. 

# Installing Monitoring Agent for WebSphere MQ

Install the Monitoring Agent for WebSphere MQ on your Docker host. The default installation directory on Linux systems is /opt/ibm/apm/agent. For more information on installing the agent, see the "Installing your agents" section in the IBM Performance Management Knowledge Center (http://www-01.ibm.com/support/knowledgecenter/SSHLNR_8.1.1/com.ibm.pm.doc/install/onprem_install_intro.htm). 

Note: if you do not want to use the MQ Agent on Docker host directly, you must set SKIP_PRECHECK to YES before installation. For example:

~~~
export SKIP_PRECHECK=YES
~~~

If you already configured an IBM MQ Advanced for Developers Docker Container image, you want to use the IBM Performance Management to monitor that, please flow the session of "Changing existing image".

If you do not have any existing IBM MQ Advanced for Developers Docker Container image, please follow the session of "Building the image".

# Changing existing image

There is a shell script(patch.sh) in this repository that can help you copying the scripts into your existing container like below:

~~~
./patch.sh ${CONTAINER_ID}
~~~

You can get your container id via the Docker command "docker ps".

After applying the changes to your Docker container, you can update and commit your image.

~~~
docker commit -m "enable APM monitoring" -a "DCC"  ${CONTAINER_ID} ibmimages/mqadvanced:v2
~~~

You will have a new image in your repository named ibmimages/mqadvanced:v2.

When you run the image, accept the terms of the IBM MQ for Developers license by specifying the environment variable "LICENSE" equal to "accept". You can also view the license terms by setting this variable to "view". If you don't set the variable, the container is ended with a usage statement. You can view the license in a different language by setting the "LANG" environment variable.

In addition to accepting the license, you must specify a Queue Manager name by using the "MQ_QMGR_NAME" environment variable. For more information, see the ibm-messaging GitHub (http://github.com/ibm-messaging/mq-docker).

You must also mount your MQ data path and the monitoring agent home directory on Docker host into the Docker container. If you run multiple containers, you are sharing the same Performance Management installation on the Docker host.

~~~
docker run \
  --env LICENSE=accept \
  --env MQ_QMGR_NAME=QM1 \
  --volume /var/mqm:/var/mqm \
  --volume /opt/ibm/apm/agent:/opt/ibm/apm/agent \
  --entrypoint=mqwithapm \
  --publish-all\
  --detach \
  ibmimages/mqadvanced:v2
~~~

Here are the parameters descrption:
--env LICENSE=accept                           You accept the terms of the IBM MQ for Developers license
--env MQ_QMGR_NAME=QM1                         The queue manager name that runs in this container
--volume /var/mqm:/var/mqm                     The first /var/mqm stands for the data directory of your Docker host, you can change to the value that needed;
                                               the second /var/mqm stands for the data directory of your Docker container, do not change this value.
--volume /opt/ibm/apm/agent:/opt/ibm/apm/agent The first /opt/ibm/apm/agent directory stands for where are you installed IBM Performance Management on your Docker host;
                                               the second /opt/ibm/apm/agent is the home APM directory of your Docker container, do not change this value.                       
--entrypoint=mqwithapm                         Override the existing the ENTRYPOINT of the MQ docker container, note this script also includes the steps to call the ENTRYPOINT of the MQ container.
ibmimages/mqadvanced:v2                        The image you just commited.

# Building the image

The image can be built by using standard Docker commands (https://docs.docker.com/userguide/dockerimages/) against the provided Dockerfile. For example, run the following commands: 

~~~
docker build -t ibmcom/apm4mq .
~~~

An image called ibmcom/apm4mq is created in your local Docker registry.


When you run the image, accept the terms of the IBM MQ for Developers license by specifying the environment variable "LICENSE" equal to "accept". You can also view the license terms by setting this variable to "view". If you don't set the variable, the container is ended with a usage statement. You can view the license in a different language by setting the "LANG" environment variable.

In addition to accepting the license, you must specify a Queue Manager name by using the "MQ_QMGR_NAME" environment variable. For more information, see the ibm-messaging GitHub (http://github.com/ibm-messaging/mq-docker).

You must also mount your MQ data path and the monitoring agent home directory on Docker host into the Docker container. If you run multiple containers, you are sharing the same Performance Management installation on the Docker host.

For example:

~~~
docker run \
  --env LICENSE=accept \
  --env MQ_QMGR_NAME=QM1 \
  --volume /var/mqm:/var/mqm \
  --volume /opt/ibm/apm/agent:/opt/ibm/apm/agent \
  --publish-all\
  --detach \
  ibmcom/apm4mq
~~~

Here are the parameters descrption:
--env LICENSE=accept                           You accept the terms of the IBM MQ for Developers license
--env MQ_QMGR_NAME=QM1                         The queue manager name that runs in this container
--volume /var/mqm:/var/mqm                     The first /var/mqm stands for the data directory of your Docker host, you can change to the value that needed;
                                               the second /var/mqm stands for the data directory of your Docker container, do not change this value.
--volume /opt/ibm/apm/agent:/opt/ibm/apm/agent The first /opt/ibm/apm/agent directory stands for where are you installed IBM Performance Management on your Docker host;
                                               the second /opt/ibm/apm/agent is the home APM directory of your Docker container, do not change this value.                       
ibmcom/apm4mq                                  The image you just built.


# Running administrative commands

It is recommended that you configure MQ in your own custom image. However, you might need to run MQ commands directly inside the process space of the container. To run a command against a running queue manager, you can use "docker exec". If you run commands non-interactively under Bash, then the MQ environment will be configured correctly. For example: 

~~~
docker exec \
  --tty \
  --interactive \
  ${CONTAINER_ID} \
  bash -c dspmq
~~~

By using this method, you have full control over all aspects of the Performance Management installation and MQ installation.
Note: if you use this method to make changes to the filesystem, the changes will be lost if you re-created your container unless you make those changes in volumes.

# Accessing logs

You can find the Performance Management logs in the agent installation directory (e.g. /opt/ibm/apm/agent/logs/) on your docker host.

# Verifying your container is running correctly

Follow the steps to verify if the image is used as provided or has been customized: 

1. Run a container. Make sure to open expose 1414 to the host for the container to start without errors.
2. Run command "mq-agent.sh" as described in section "Running Administrative Commands" to show the status of your node. For example: 

~~~
docker exec \
  ${CONTAINER_ID} \
  bash -c "/opt/ibm/apm/agent/bin/mq-agent.sh status"
~~~
The node should be listed as running.

At this point, your container is running and you can access Performance Management console (http://www-01.ibm.com/support/knowledgecenter/SSHLNR_8.1.1/com.ibm.pm.doc/install/admin_console_start.htm) to view the performance dashboards.

# Issues and contributions

For issues that are specifically related to this Dockerfile, please use the GitHub issue tracker (https://github.com/dongcc/apmmq-docker/issues). If you submit a Pull Request related to this Dockerfile, please indicate in the Pull Request that you accept and agree to be bound by the terms of the [IBM Contributor License Agreement](CLA.md).

# License

The Dockerfile and associated scripts are licensed under the [Apache License 2.0](LICENSE). IBM MQ Advanced for Developers is licensed under the IBM International License Agreement for Non-Warranted Programs. You can check the license from the image using the "LICENSE=view" environment variable as previously described. The license can also be found [online](http://www14.software.ibm.com/cgi-bin/weblap/lap.pl?li_formnum=L-APIG-9BUHAE). Note that this license does not permit further distribution.
