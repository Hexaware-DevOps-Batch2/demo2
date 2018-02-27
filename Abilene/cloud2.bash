#!/bin/bash
HOSTS_FILE=$1
YAML_FILE=$2
REMOTE_DIR="my-projects/demo2"
HOST_ADDR=""
exitCode=0
exitMssg=""

if [ $# -lt 2 ];then
 echo "This scripts needs 2 arguments to run (host configuration file and yml file)" >&2
 exit 1
fi

function validateFile {
  if [ ! -s $1 ]; then
    echo "Could not find file ${1} or it is empty, please verify" >&2
    exit 1
  fi
}

validateFile $HOSTS_FILE
validateFile $YAML_FILE

# check host config file has correct elements number, use later

nFileWords=`wc -w ${HOSTS_FILE} | awk '{print $1}'`

if [ $nFileWords -le 0 ]; then
  echo "Please check file ${HOSTS_FILE} is correct" >&2
  exit 1
else
  echo "Total elements in ${HOSTS_FILE} are: ${nFileWords}"
fi

 function checkExitStatusCode {
    if [ "$1" -eq "0" ]; then
      echo "OK "
    else
      echo "ERROR" >&2
      exit 1
    fi
 }
 function makeRemoteDirectory {
    HOST_ADDR="${1}@${2}"
   echo "---- Connecting to host ${HOST_ADDR}"
   echo "1.Creating remote dir ${REMOTE_DIR}"
   # echo "${2}.pem"
   ssh -i "${2}.pem" ${HOST_ADDR} bash -c "'

   if [ ! -d $HOME/${REMOTE_DIR} ]; then
    mkdir -m 777 -p $HOME/${REMOTE_DIR}
    chmod 777 $HOME/my-projects
   fi
   '"
   checkExitStatusCode $?
 }

 function updateRemoteFile {
        echo "Updating file..."
        HOST_ADDR="${1}@${2}"
        ssh -i "${2}.pem" ${HOST_ADDR} bash -c "'
                cd $HOME/${REMOTE_DIR}
                grep -i address ${YAML_FILE} | sed -i 's/[0-9][0-9][0-9].[0-9][0-9][0-9].[0-9].[0-9]/"${2}"/' ${YAML_FILE}
                grep -i date ${YAML_FILE} | sed -i 's/[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]/`date +%Y-%m-%d`/' ${YAML_FILE}
                grep -i time ${YAML_FILE} | sed -i 's/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/`date +%T`/' ${YAML_FILE}
                # grep -i username ${YAML_FILE} | sed -i 's/"username:[a-zA-Z]\*"/"username:`whoami`"/' ${YAML_FILE}
                # grep -i homeDirectory ${YAML_FILE} | sed -i 's/\/[a-zA-Z]*\/[a-zA-Z]*/`printenv HOME`/' ${YAML_FILE}
                # grep -i lang ${YAML_FILE} | sed -i 's/[a-z]\{2\}_[A-Z]\{2\}.[A-Z]\+\-[0-9]/`printenv LANG`/' ${YAML_FILE}
         '"
        checkExitStatusCode $?
 }

 function copyFileToRemote {
        HOST_ADDR="${1}@${2}"
    echo "2.Copying ${YAML_FILE}"
        filePath="${REMOTE_DIR}/${YAML_FILE}"
        echo ${filePath}
        exitCode=$(ssh -i "${2}.pem" ${HOST_ADDR} bash -c "'
                cd ${HOME}/${REMOTE_DIR}
                if [ -s ${YAML_FILE} ]; then
                        grep -i date ${YAML_FILE} | sed -i 's/[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]/`date +%Y-%m-%d`/' ${YAML_FILE}
                        grep -i time ${YAML_FILE} | sed -i 's/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/`date +%T`/' ${YAML_FILE}
                        echo "0"
                else
                        echo "1"
						                fi
        '")

        if [ "$exitCode" = "1" ]; then
                scp -p -i "${2}.pem" ${YAML_FILE} ${HOST_ADDR}:${HOME}/${REMOTE_DIR}
                ssh -i "${2}.pem" ${HOST_ADDR} bash -c "'
                chmod 777 ${HOME}/${REMOTE_DIR}/${YAML_FILE}
                '"
                checkExitStatusCode $? &&
                updateRemoteFile $1 $2
        fi
 }

 total_lines=`wc -l ${HOSTS_FILE} | awk '{print $1}'`
i=1
while [ $i -le $total_lines ]; do
   line=`sed -n -e ${i}p ${HOSTS_FILE}`
   HOST_USER=`echo $line | awk '{print $1}'`
   IP_ADDR=`echo $line | awk '{print $2}'`
   makeRemoteDirectory $HOST_USER $IP_ADDR &&
   copyFileToRemote $HOST_USER $IP_ADDR &&
   if [ $? -eq 0 ]; then
        today=`date +%Y-%m-%d`
        echo "${IP_ADDR}:Success:${today}"
        else
                echo "${IP_ADDR}:Fail:${today}"
        fi
        i=$(($i + 1 ))
done