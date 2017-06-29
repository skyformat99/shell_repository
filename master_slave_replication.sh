#!/usr/bin/env bash
# blog uri: http://linuxnote.blog.51cto.com/9876511/1652016
#!/bin/bash
#Target: Auto Make And Check Mysql Master-Slave
#Date: 2015-05-17
#Author: Jacken
#QQ 654001593
#QQ Group 170544180
#Version: 1.0
#
#Note：Have To Exec 1 On Master,Then Exec 2 On SLAVE_DIR,On Correspond Machine To Select "Show Status"
#Only Allow Define Variable
shopt -s -o nounset
#
#####################################################################
#####################################################################
##########Define Varabile
#Define Master And Slave Database Ipaddress.
MASTER_IP=192.168.1.3
SLAVE_IP=192.168.1.4
#
#Define Master Super User Name And Password.
MASTER_USER=root
MASTER_PASSWD=master123
#
#Define Slave Super User Name And Password.
SLAVE_USER=root
SLAVE_PASSWD=slave123
#
#Define Master-to-Slave Grant  User & Password & Host
GRANT_USER=grantuser
GRANT_PASSWD=grantpasswd
GRANT_HOST=%
#
#Sync Database
RSDB=*.*
#
#Define Mysql install Directory
MASTER_DIR=/usr/local/mysql
SLAVE_DIR=/usr/local/mysql
#
#Define Device Name.
DEV=eth0
#
#Get Ipaddress For Exec Scripts Machine
GETIP=$(ifconfig $DEV| sed -n '/inet addr:/p'|awk '{print $2}'| awk -F: '{print $2}')
#####################################################################
#####################################################################
#
#Only For Super User To Exec
if [ $UID -ne 0 ];then
    echo -e '\e[31mSorry,This Script Must Be Super User To Exec!\e[0m'
    exit 2
fi
#
#
#####################################################################
#####################################################################
#
#Define Master database Operations.
MYSQL_MIN="$MASTER_DIR/bin/mysql -u$MASTER_USER -p$MASTER_PASSWD -e"
#
function MASTER_DO {
#Backup And Judge My.cnf
if [ -f /etc/my.cnf ];then
    cp /etc/my.cnf /etc/my.cnf$$
else
    cp $MASTER_DIR/share/mysql/my-medium.cnf  /etc/my.cnf
fi
#Grant Slave Database Access Master Database.
$MASTER_DIR/bin/mysql -u$MASTER_USER -p$MASTER_PASSWD -e "grant all on $RSDB to '$SLAVE_USER'@'$SLAVE_IP' identified by '$SLAVE_PASSWD';"
#Grant Master-Slave Sync User.
$MYSQL_MIN "grant replication slave on $RSDB to \"$GRANT_USER\"@\"$GRANT_HOST\" identified by \"$GRANT_PASSWD\";"
$MYSQL_MIN "flush privileges;"
}
#
#
#####################################################################
#####################################################################
#
#Define Slave database Operations.
#
function SLAVE_DO(){
MYSQL_SIN="$SLAVE_DIR/bin/mysql -u$SLAVE_USER -p$SLAVE_PASSWD -e"
#Get Master Database status.
MASTER_INFO=`$SLAVE_DIR/bin/mysql -h$MASTER_IP -u$SLAVE_USER -p$SLAVE_PASSWD -e "show master status;"|sed -n '/mysql/p'`
#
#Get Log_File
LOG_FILE=`echo $MASTER_INFO|awk  '{print $1}'`
#Get Log_Pos
LOG_POS=`echo $MASTER_INFO|awk '{print $2}'`
#
#Get Slave Database Status
SYNC_INFO=`$MYSQL_SIN "show slave status \G;"|grep Runnning > /dev/null 2>&1`
#
#Judge Yes Or No
SLAVE_IO_STATUS=`echo $SYNC_INFO|sed -n '/IO/p'|awk -F: '{print $2}'`
SLAVE_SQL_STATUS=`echo $SYNC_INFO|sed -n '/SQL/p'|awk -F: '{print $2}'`
#Grant Master User To Access Slave Database.
`$MYSQL_SIN "grant all privileges on $RSDB to \"$MASTER_USER\"@\"$MASTER_IP\" identified by \"$MASTER_PASSWD\";"`
#
#Backup And Judge /etc/My.cnf
if [ -f /etc/my.cnf ];then
    cp /etc/my.cnf /etc/my.cnf$$
else
    cp $MASTER_DIR/share/mysql/my-medium.cnf  /etc/my.cnf
fi
#
#Modify Slave Server-id
sed -i '/^server-id/s/1/2/' /etc/my.cnf
#
#Add Master Information On Slave
$MYSQL_SIN "change master to master_host='$MASTER_IP',master_user='$GRANT_USER',master_password='$GRANT_PASSWD',master_log_file='$LOG_FILE',master_log_pos=$LOG_POS;"
$MYSQL_SIN "slave start;"
}
#
#
#####################################################################
#####################################################################
#
#Judge Master-Slave Status On Slave To Exec!
function SYNC_STATUS_S {
MYSQL_SIN="$SLAVE_DIR/bin/mysql -u$SLAVE_USER -p$SLAVE_PASSWD -e"
#Get Sync Information
SYNC_INFO=`$MYSQL_SIN 'show slave status \G'|grep Running`
#
#Judge Yes Or No
SLAVE_IO_STATUS=`echo $SYNC_INFO|awk  '{print $2}'`
SLAVE_SQL_STATUS=`echo $SYNC_INFO|awk '{print $4}'`
#
#Reply Master-Slave Status Information.
if [[ "$SLAVE_IO_STATUS" == 'Yes' && "$SLAVE_SQL_STATUS" == 'Yes' ]];then
    echo -e '\e[32mThe Database Sync Is Successfuly!\e[0m'
else
    echo -e '\e[31mThe Database Sync Is Failure!\e[0m'
    echo -e '\e[31mPlease Check!Exit....\e[0m'
    exit 2
fi
}
#Judge Master-Slave Status On Master To Exec!
function SYNC_STATUS_M {
MYSQL_MIN="$MASTER_DIR/bin/mysql -h$SLAVE_IP -u$MASTER_USER -p$MASTER_PASSWD -e"
#
#Get Sync Information
SYNC_INFO=`$MYSQL_MIN 'show slave status \G'|grep Running`
#
#Judge Yes Or No
SLAVE_IO_STATUS=`echo $SYNC_INFO|awk  '{print $2}'`
SLAVE_SQL_STATUS=`echo $SYNC_INFO|awk '{print $4}'`
#Reply Master-Slave Status Information.
if [[ "$SLAVE_IO_STATUS" == 'Yes' && "$SLAVE_SQL_STATUS" == 'Yes' ]];then
    echo -e '\e[32mThe Database Sync Is Successfuly!\e[0m'
else
    echo -e '\e[31mThe Database Sync Is Failure!\e[0m'
    echo -e '\e[31mPlease Check!Exit....\e[0m'
    exit 2
fi
}
#
#####################################################################
#####################################################################
#
#Judge Master Database Machine!
function JUDGE_MASTER_ID() {
if [ ! "$GETIP"  ==  "$MASTER_IP" ];then
    echo -e '\e[31mYour Choice Error,This Option Only Select On Master Machine!\e[0m'
    exit 2
fi
}
#
#####################################################################
#####################################################################
#
#Judge Master Database Machine!
function JUDGE_SLAVE_ID() {
if [ ! "$GETIP"  ==  "$SLAVE_IP" ];then
    echo -e '\e[31mYour Choice Error,This Option Only Select On Slave Machine!\e[0m'
    exit 2
fi
}
#
#####################################################################
#####################################################################
#####################################################################
#
PS3="Please Input Number:"
select i in "Configure Master Database(On Master)" "Configure Slave Database(On Slave)" "Show Master-Slave Status(On Master)" "Show Master-Slave(On Slave)" "Exit"
do
CHOOSE=$REPLY
case $CHOOSE in
#####################################################################
1)
JUDGE_MASTER_ID
MASTER_DO
    if [ $? -eq 0 ];then
        echo -e '\e[32mConfigure Master Database Successfully!\e[0m'
    else
        echo -e '\e[31mConfigure Master Database Failure!\e[0m'
    fi
;;
#####################################################################
2)
JUDGE_SLAVE_ID
SLAVE_DO
    if [ $? -eq 0 ];then
        echo -e '\e[32mConfigure Slave Database Successfully!\e[0m'
    else
        echo -e '\e[31mConfigure Slave Database Failure!\e[0m'
    fi
;;
#####################################################################
3)
JUDGE_MASTER_ID
SYNC_STATUS_M
;;
#####################################################################
4)
JUDGE_SLAVE_ID
SYNC_STATUS_S
;;
#####################################################################
5)
echo -e '\e[32mByeBye.\e[0m'
exit
;;
#####################################################################
*)
echo -e '\e[31mInput Error,Please Input Again!\e[0m'
esac
done