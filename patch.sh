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

if [ $# != 1 ] ;then
  echo "Usage: $0 containerid"
  exit 1;
fi

longid=`docker inspect -f '{{.Id}}' $1`
if [ ! $longid ] ;then
  echo "Failed"
  exit 1;
fi

#echo "$longid"
echo "Applying to container :$1..."

cp ./mqwithapm /var/lib/docker/aufs/mnt/${longid}/usr/local/bin
cp ./mq-agent4docker.sh /var/lib/docker/aufs/mnt/${longid}/usr/local/bin

echo "Done"

