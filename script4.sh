#!/bin/bash

/bin/echo -e "\033[31mApplying patch4..Please Wait! \033[0m"

/var/lib/ambari-server/resources/scripts/configs.sh -u admin -p admin -port 8080 set `hostname` hdptest ranger-ugsync-site  "ranger.usersync.unix.minUserId" "1500" &>/tmp/var_out4

sleep 2

/bin/echo "SELECT * FROM serviceconfig WHERE service_name='RANGER' and service_config_id NOT IN (SELECT service_config_id FROM ( SELECT service_config_id FROM serviceconfig ORDER BY service_config_id DESC LIMIT 1 ) foo );" |PGPASSWORD='bigdata' psql -U ambari &>/tmp/selectsc.log4

sleep 2

/bin/echo "DELETE FROM serviceconfig WHERE service_name='RANGER' and service_config_id NOT IN (SELECT service_config_id FROM ( SELECT service_config_id FROM serviceconfig ORDER BY service_config_id DESC LIMIT 1 ) foo );" |PGPASSWORD='bigdata' psql -U ambari &>/tmp/deletesc.log4

sleep 2

/usr/sbin/useradd user1 & >/tmp/useradd.log4

sleep 2

curl -u admin:admin -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Stop RANGER via REST"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' http://`hostname`:8080/api/v1/clusters/hdptest/services/RANGER &>>/tmp/out4

sleep 10

curl -u admin:admin -i -H 'X-Requested-By: ambari' -X PUT -d  '{"RequestInfo": {"context" :"Start RANGER via REST"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}'  http://`hostname`:8080/api/v1/clusters/hdptest/services/RANGER &>>/tmp/out4

sleep 2

session_id=`cat /var/log/ambari-server/ambari-server.log|grep "Got Session ID"|tail -n 1 |rev|cut -d' ' -f3|rev`
curl -u admin:admin -i -H 'X-Requested-By:ambari' -H "Cookie: AMBARISESSIONID=$session_id" -X GET http://`hostname`:8080/api/v1/logout &>/tmp/admin_logout
rm -fr ./doSet*

/bin/echo -e "\033[32mPatch successfully applied \033[0m"
