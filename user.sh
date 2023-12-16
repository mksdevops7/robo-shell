#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"0
B="\e[1m"
MONGODB_HOST=mongodb.mksdevops.online

sudo timedatectl set-timezone Asia/Kolkata
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-TIMESTAMP.log"

exec &>> $LOGFILE 
# executes a Shell command without creating a new process.
# instead of giving $LOGFILE every where we are giving here to avoid repetition

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

dnf module disable nodejs -y
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:18 -y
VALIDATE $? "Enabling nodejs 18"

dnf install nodejs -y
VALIDATE $? "Installing nodejs 18"

id roboshop #if user roboshop doesn't exist,it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "Adding user roboshop"
else
    echo -e "user roboshop already exists $Y SKIPPING..$N"
fi

mkdir -p /app

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip
VALIDATE $? "Downloading user application"

cd /app 

unzip /tmp/user.zip
VALIDATE $? "Unzipping user"

npm install 
VALIDATE $? "Installing Dependencies"

cp /home/centos/robo-shell/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying user service file"

systemctl daemon-reload
VALIDATE $? "reloading user daemon"

systemctl enable user 
VALIDATE $? "Enabling user"

systemctl start user
VALIDATE $? "Starting user"

cp /home/centos/robo-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y
VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/user.js
VALIDATE $? "Loading user data into MongoDB"

