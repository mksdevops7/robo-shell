#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
B="\e[1m"

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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading payment"

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzipping payment"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing Dependencies"

cp /home/centos/robo-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "Copying payment service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reaload"

systemctl enable payment  &>> $LOGFILE
VALIDATE $? "Enable payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Start payment"