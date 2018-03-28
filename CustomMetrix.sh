#!/bin/sh
CUR_DIR=/home/ec2-user/cloudwatch

export JAVA_HOME=/usr/lib/jvm/jre
export AWS_CLOUDWATCH_HOME=/opt/aws/apitools/mon
export EC2_REGION=ap-northeast-1
export AWS_CREDENTIAL_FILE=${CUR_DIR}/credential
InstanceId=`cat /var/tmp/aws-mon/instance-id`
# 設定ファイル
PROCESSCONFIG=${CUR_DIR}/process-conf.txt

# Process Check(設定したファイルから読み込む)
cat ${PROCESSCONFIG} | sed '/^$/d' | grep -v '^#.*' | while read PROCESS
do
  COUNT=`ps aux | grep ${PROCESS} | grep -v grep | wc -l`
echo ${PROCESS}:${COUNT}
  /opt/aws/bin/mon-put-data --metric-name ${PROCESS} --namespace "CustomMetrix" --dimensions "InstanceId=${InstanceId}" --value ${COUNT}
done

# LoadAverage(1分間の測定値を取得)
/opt/aws/bin/mon-put-data --metric-name "LoadAverage" --namespace "CustomMetrix" --dimensions "InstanceId=${InstanceId}" --value `cat /proc/loadavg | awk '{print $1;}'`
