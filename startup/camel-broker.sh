#!/bin/sh 

# Install as /usr/local/bin/camel-broker-sqs.sh
# Call by installing camel-broker-sqs.service in /etc/systemd/system/multi-user.target.wants/ & then systemctl enable/start camel-broker-sqs

SERVICE_NAME=camel-broker-sqs
HOME_PATH=/home/ec2-user
PATH_TO_JAR=$HOME_PATH/broker-1.0-SNAPSHOT.jar
PID_PATH_NAME=/tmp/camel-broker-sqs-pid
JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto.x86_64
PATH=$JAVA_HOME/bin:$PATH
cd $HOME_PATH
case $1 in 
start)
       echo "Starting $SERVICE_NAME ..."
  if [ ! -f $PID_PATH_NAME ]; then 
       nohup java -jar $PATH_TO_JAR /tmp 2>> /dev/null >>/dev/null &      
                   echo $! > $PID_PATH_NAME  
       echo "$SERVICE_NAME started ..."         
  else 
       echo "$SERVICE_NAME is already running ..."
  fi
;;
stop)
  if [ -f $PID_PATH_NAME ]; then
         PID=$(cat $PID_PATH_NAME);
         echo "$SERVICE_NAME stoping ..." 
         kill $PID;         
         echo "$SERVICE_NAME stopped ..." 
         rm $PID_PATH_NAME       
  else          
         echo "$SERVICE_NAME is not running ..."   
  fi    
;;    
restart)  
  if [ -f $PID_PATH_NAME ]; then 
      PID=$(cat $PID_PATH_NAME);    
      echo "$SERVICE_NAME stopping ..."; 
      kill $PID;           
      echo "$SERVICE_NAME stopped ...";  
      rm $PID_PATH_NAME     
      echo "$SERVICE_NAME starting ..."  
      nohup java -jar $PATH_TO_JAR /tmp 2>> /dev/null >> /dev/null &            
      echo $! > $PID_PATH_NAME  
      echo "$SERVICE_NAME started ..."    
  else           
      echo "$SERVICE_NAME is not running ..."    
     fi     ;;
 esac