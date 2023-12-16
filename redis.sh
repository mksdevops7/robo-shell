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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
VALIDATE $? "Installing remi-release 8"

dnf module enable redis:remi-6.2 -y
VALIDATE $? "enabling Redis remi6.2"

dnf install redis -y
VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis
VALIDATE $? "Enabling redis"

systemctl start redis
VALIDATE $? "Started Redis"