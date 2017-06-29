#!/bin/bash

HOSTNAME="192.168.0.2"
PORT="3306"
USERNAME="root"
PASSWORD="root"
DBNAME="testDB"
toLogin="mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD}"

while  read line;
do
    user_id=`echo $line | awk -F "\n" '{ printf("%s", $1)}'`
    # 插入 tbl_operate_user 用户表

    ${toLogin} -e "INSERT INTO ${DBNAME}.\`tbl_operate_user\`
        (user_id, user_name, user_erp_no, user_type,ope_dep_id,ope_phone_num,email,user_stat, create_time, update_time)
        VALUES('$user_id', '$user_id' , '$user_id', '', '00002', '', '', '1', NOW(), NOW())"
    echo "INSERT INTO ${DBNAME}.\`tbl_operate_user\`
        (user_id, user_name, user_erp_no, user_type,ope_dep_id,ope_phone_num,email,user_stat, create_time, update_time)
        VALUES('$user_id', '$user_id' , '$user_id', '', '00003', '', '', '1', NOW(), NOW());" >> insert.sql


    #   插入角色
    ${toLogin} -e "INSERT INTO ${DBNAME}.\`tbl_ouser_role_rel\` (user_id, role_id, create_time, update_time) VALUES('$user_id', '05', NOW(),  NOW())"
    echo "INSERT INTO ${DBNAME}.\`tbl_ouser_role_rel\` (user_id, role_id, create_time, update_time) VALUES('$user_id', '05', NOW(), NOW());" >> insert.sql

    # 用户业务线表
    ${toLogin} -e "INSERT INTO  ${DBNAME}.\`tbl_operate_user_busitype\`
                (user_id, busi_type_id, create_time, update_time)
                VALUES('$user_id', 'all', NOW(),NOW())"
    echo "INSERT INTO ${DBNAME}.\`tbl_operate_user_busitype\`
                (user_id, busi_type_id, create_time, update_time)
                VALUES('$user_id', 'all', NOW(),NOW());" >> insert.sql
    #
    done < input.data


