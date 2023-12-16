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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling current NodeJS Version"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling nodeJS 18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing nodeJS"

id roboshop #if roboshop user won't present it is failure so..
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding user roboshop"
else
    echo -e "user roboshop already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Making app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading catalogue app code"

cd /app &>> $LOGFILE

unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unzipping catalogue"

npm install &>> $LOGFILE
VALIDATE $? "Installing Dependencies"

cp  /home/centos/robo-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Coping catalogue service file"
#used absolute path bcz catalogue service file exits there

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting catalogue"

cp /home/centos/robo-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading catalogue data into MongoDB"
