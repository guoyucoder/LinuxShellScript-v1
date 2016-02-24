
sudo sh /etc/init.d/check_request.sh &

restartPath=/etc/init.d/jettyRestart

restartPath=/etc/init.d/tomcatRestart


if [ ! -f "$restartPath" ];then
    touch $restartPath
fi

if [ -f "$restartPath" ];then
    rm $restartPath
fi

nohup sh /etc/init.d/check_request.sh &
nohup sh /etc/init.d/checkRunningProcess.sh "tomcat" &
nohup sh /etc/init.d/checkRunningProcess.sh "jetty" &

ps -ef | grep jetty | grep -v grep


