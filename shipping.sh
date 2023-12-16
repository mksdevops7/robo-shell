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

dnf install maven -y &>> $LOGFILE

id roboshop #if user roboshop doesn't exist,it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "Adding user roboshop"
else
    echo -e "user roboshop already exists $Y SKIPPING..$N"
fi

mkdir -p /app
VALIDATE $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading shipping"

cd /app
VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "renaming jar file"

cp /home/centos/robo-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copying shipping service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "deamon reload"

systemctl enable shipping  &>> $LOGFILE
VALIDATE $? "enable shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "start shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "install MySQL client"

mysql -h mysql.mksdevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "loading shipping data"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restart shipping"