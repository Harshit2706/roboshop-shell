COMPONENT=mysql
source common.sh
RABBITMQ_APP_USER_PASSWORD=$1

if [ -z "$1" ]; then
  echo "Input password is missing"
  exit
fi


PRINT "Configure Erlang Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>$LOG
STAT $?

PRINT "Install Erlang"
yum install erlang -y &>>$LOG
STAT $?

PRINT "Configure RabbitMQ Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>$LOG
STAT $?

PRINT "Install RabbitMQ"
yum install rabbitmq-server -y &>>$LOG
STAT $?

PRINT "Enable RabbitMQ service"
systemctl enable rabbitmq-server &>>$LOG
STAT $?

PRINT "Start RabbitMQ service"
systemctl start rabbitmq-server &>>$LOG
STAT $?

PRINT "Add Application user"
rabbitmqctl add_user roboshop ${RABBITMQ_APP_USER_PASSWORD} &>>$LOG
STAT $?

PRINT "Configure Application user"
rabbitmqctl set_user_tags roboshop administrator &>>$LOG
STAT $?

PRINT "Configure Application user Permissions"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG
STAT $?

#1