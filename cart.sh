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

# exec &>> $LOGFILE 
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

mkdir -p /app &>> $LOGFILE 
VALIDATE $? "creating app directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE 
VALIDATE $? "Downloading cart application"

cd /app &>> $LOGFILE 

unzip -o /tmp/cart.zip  &>> $LOGFILE 
VALIDATE $? "unzipping cart"

npm install #&>> $LOGFILE 
VALIDATE $? "Installing dependencies"

# use absolute, because cart.service exists there
cp /home/centos/robo-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE 
VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $LOGFILE 
VALIDATE $? "cart daemon reload"

systemctl enable cart &>> $LOGFILE 
VALIDATE $? "Enable cart"

systemctl start cart &>> $LOGFILE 
VALIDATE $? "Starting cart"