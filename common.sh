STAT() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32mSUCCESS\e[0m"
else
  echo -e "\e[31mFAILURE\e[0m"
  echo Check the error in $LOG file
fi

}

PRINT() {
  echo " .................. $1 ...................... " >>${LOG}
  echo -e "\e[33m$1\e[0m"

}

LOG=/tmp/$COMPONENT.log
rm -f $LOG

DOWNLOAD_APP_CODE() {
  if [ ! -z "$APP_USER" ]; then
    PRINT "Adding Application User"
    id roboshop &>>$LOG
    if [ $? -ne 0 ]; then
      useradd roboshop &>>$LOG
    fi
    STAT $?
  fi

  PRINT "Download App Content"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/roboshop-devops-project/$COMPONENT/archive/main.zip" &>>$LOG
STAT $?

PRINT "Remove Previous Version of App"
cd $APP_LOC &>>$LOG
rm -rf $CONTENT &>>$LOG
STAT $?

PRINT "Extracting App Content"
unzip -o /tmp/$COMPONENT.zip &>>$LOG
STAT $?
}

SYSTEMD_SETUP() {
  PRINT "Configure endpints for SystemD Configuration"
  sed -i -e 's/MONGO_DNSNAME/dev-mongodb.devopsb69.online/' 's/REDIS_ENDPOINT/dev-redis.devopsb69.online/' -e 's/CATALOGUE_ENDPOINT/dev-catalogue.devopsb69.online/' /home/roboshop/${COMPONENT}/systemd.service &>>$LOG
  STAT $?

  PRINT "Setup SystemD Service"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>$LOG
  STAT $?

  PRINT "Reload SystemD"
  systemctl daemon-reload &>>$LOG
  STAT $?

  PRINT "Restart ${COMPONENT}"
  systemctl restart ${COMPONENT} &>>$LOG
  STAT $?

  PRINT "Enable ${COMPONENT} Service"
  systemctl enable ${COMPONENT} &>>$LOG
  STAT $?
}

NODEJS() {
  APP_LOC=/home/roboshop
  CONTENT=$COMPONENT
  APP_USER=roboshop
  PRINT "Install NodeJS Repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOG
STAT $?

PRINT "Install NodeJS"
yum install nodejs -y &>>$LOG
STAT $?



DOWNLOAD_APP_CODE

mv ${COMPONENT}-main ${COMPONENT}
cd ${COMPONENT}

PRINT "Install NodeJS Dependencies for App"
npm install &>>$LOG
STAT $?

SYSTEMD_SETUP
}

JAVA() {
  APP_LOC=/home/roboshop
  CONTENT=$COMPONENT
  APP_USER=roboshop

  PRINT "Install Maven"
  yum install maven -y &>>$LOG
  STAT $?

  DOWNLOAD_APP_CODE

  mv ${COMPONENT}-main ${COMPONENT}
  cd ${COMPONENT}

  cd /home/roboshop/$COMPONENT
  PRINT "Download Maven Dependencies"
  mvn clean package &>>$LOG  && mv target/$COMPONENT-1.0.jar $COMPONENT.jar &>>$LOG
  STAT $?

  SYSTEMD_SETUP

}


PYTHON() {
  APP_LOC=/home/roboshop
  CONTENT=$COMPONENT
  APP_USER=roboshop

  PRINT "Install Python"
  yum install python36 gcc python3-devel -y &>>$LOG
  STAT $?

  DOWNLOAD_APP_CODE
  mv ${COMPONENT}-main ${COMPONENT}
  cd ${COMPONENT}

  PRINT "Install Python Dependencies"
  pip3 install -r requirements.txt &>>$LOG
  STAT $?

  USER_ID=$(id -u roboshop)
  GROUP_ID=$(id -g roboshop)
  sed -i -e "/uid/ c uid = ${USER_ID}" -e "/uid/ c uid = ${GROUP_ID}" ${COMPONENT}.ini

  SYSTEMD_SETUP
}

#1
