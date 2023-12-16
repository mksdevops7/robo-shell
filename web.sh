#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
B="\e[1m"
MONGODB_HOST=mongodb.mksdevops.online

sudo timedatectl set-timezone Asia/Kolkata
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $B $R FAILED $N $N"
        exit 1
    else
        echo -e "$2 ... $B $G SUCCESS $N $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$B $R ERROR:: become root user to Execute the script $N $N"
    exit 1
else
    echo -e "$B $Y You are a root user $N $N"
fi

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enable nginx" 

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "removed default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Downloaded web application"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "moving nginx html directory"

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping web"
 
cp /home/centos/robo-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE 
VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restarted nginx"