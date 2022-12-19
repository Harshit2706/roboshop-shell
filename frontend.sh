COMPONENT=frontend
CONTENT="*"
source common.sh

PRINT "Install Nginx"
yum install nginx -y &>>$LOG
STAT $?

APP_LOC=/usr/share/nginx/html

DOWNLOAD_APP_CODE

mv ${COMPONENT}-main/static/* .

PRINT "Copy RoboShop Configuration File"
mv ${COMPONENT}-main/localhost.conf /etc/nginx/default.d/roboshop.conf
STAT $?

PRINT "Update RoboShop Configuration"
sed -i -e '/catalogue/ s/localhost/dev-catalogue.harshit-creator.online/' -e '/user/ s/localhost/dev-user.harshit-creator.online/' -e '/cart/ s/localhost/dev-cart.harshit-creator.online/' -e '/shipping/ s/localhost/dev-shipping.harshit-creator.online/' -e '/payment/ s/localhost/dev-payment.harshit-creator.online/' /etc/nginx/default.d/roboshop.conf
STAT $?

PRINT "Enable Nginx Service"
systemctl enable nginx &>>$LOG
STAT $?

PRINT "Start Nginx Service"
systemctl restart nginx &>>$LOG
STAT $?
