#!/bin/sh
# © Copyright IBM Corporation 2015.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CANDLE_HOME=/opt/ibm/apm/agent
PRODUCTCODE=mq
INSTANCENAME=${MQ_QMGR_NAME}
SILENTCONFIG=${CANDLE_HOME}/config/${MQ_QMGR_NAME}_mqsilent.txt
KMQENVIRONMENT=${CANDLE_HOME}/config/.mq.environment
MQ_DOCKER_USER=root
MQ_DOCKER_GROUP=root

chown_home()
{
    sudo chown -R $MQ_DOCKER_USER:$MQ_DOCKER_GROUP $CANDLE_HOME >/dev/null 2>&1
}

change_environment()
{
    grep -q "KMQ_LATEST_WMQ_INSTALLPATH=/opt/mqm" $KMQENVIRONMENT
    if [ $? -eq 0 ]
    then
        echo "KMQ_LATEST_WMQ_INSTALLPATH=/opt/mqm already exists."
    else
        {
        sed -i '$a\KMQ_LATEST_WMQ_INSTALLPATH=/opt/mqm' $KMQENVIRONMENT
        echo "KMQ_LATEST_WMQ_INSTALLPATH=/opt/mqm has been added."
        }
    fi

    grep -q "LD_LIBRARY_PATH=/opt/mqm/lib64:" $KMQENVIRONMENT
    if [ $? -eq 0 ]
    then
        echo "LD_LIBRARY_PATH=/opt/mqm/lib64 already exists."
    else
        {
            sed -i 's/LD_LIBRARY_PATH=/&\/opt\/mqm\/lib64:/' $KMQENVIRONMENT
            echo "/opt/mqm/lib64 has been added."
        }
    fi
}

start_instance ()
{
  #echo "basename:$(basename $0)"
  if [ ! -f ${CANDLEHOME}/config/${PRODUCTCODE}\_${INSTANCENAME}.environment -a -z "`ls ${CANDLEHOME}/config/*_${PRODUCTCODE}\_${INSTANCENAME}.cfg 2>/dev/null`" ] ; then
    echo "The instance \"${INSTANCENAME}\" is not configured for this agent, will generate a slient config..."
    echo "QMNAME=${MQ_QMGR_NAME}\nAGTNAME=${HOSTNAME}\n">${SILENTCONFIG}

    #`dirname $0`/mq-agent.sh config ${INSTANCENAME} ${SILENTCONFIG}
    ${CANDLE_HOME}/bin/mq-agent.sh config ${INSTANCENAME} ${SILENTCONFIG}
  fi

  ${CANDLE_HOME}/bin/mq-agent.sh start ${INSTANCENAME} 
}

stop_instance()
{
  echo "Stopping agent instance ${INSTANCENAME}..."
  ${CANDLE_HOME}/bin/mq-agent.sh stop ${INSTANCENAME} 
}

if [ "$1" = "start" ]; then
  chown_home
  change_environment
  start_instance
elif [ "$1" = "stop" ]; then
  stop_instance
else
  echo "Invalid parameter,only start|stop allowed";
fi
