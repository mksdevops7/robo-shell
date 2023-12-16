#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
B="\e[1m"
$MONGDB_HOST=mongodb.mksdevops.online

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

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "Disable current MySQL version"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Copied MySQl repo"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE 
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting  MySQL Server" 

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "Setting  MySQL root password"