#!/bin/bash

#checkRunningProcess.sh
#输入服务名称,如果存在 该服务已停止,并且 "服务名 + Restart" 文件存在时,就把该服务重启,并且发送给相关人员
#编写人:上海澄泓信息科技,郭宇,2016/01/22

#重启时,发送邮件给谁
emails=("2531868871@qq.com" "chuxiong.ren@chenghong.cc" "1270040457@qq.com" "guoyu@chenghong.cc");

#提示语,主题
subject="(测试)服务器已经自动重启了"

#请求间隔(秒)
sheepTime=60

#发送邮件
mySendMail(){
    local emailBody="$(mydate), $subject, 监控shell脚本检测到 $1 服务器非正常关机了,所以把 $1 服务器重启了."
    echo $emailBody
    for email in ${emails[@]};
    do
        echo "$(mydate), sendMail To=$email"
        echo $emailBody | mail -s "$1 $subject" $email;
    done
}


mydate()
{
 date "+%Y-%m-%d %H:%M:%S"
};

#检查
checkRunningProcess_main(){
	trap `echo 服务重启出了问题` 6
	local ps_out=`ps -ef | grep $1 | grep -v grep | grep -v "tail -f" | wc -l`
	if [ "$ps_out" != 0 ];then
		echo "$(mydate) $1 Running"
	else
		echo "$(mydate) $1 Not Running"
		if [ -f "$1Restart" ];then
			sudo service $1 stop;
			sleep 10;
			sudo service $1 start;
			mySendMail $1;
		else
			echo "$(mydate) $1Restart 文件不存在, 所以判断为正常情况下关的服务器, 所以没有进行服务器重启操作"
        fi
    fi
    echo
}


#获得日志保存目录
getSaveLogsPath(){
    local saveFilePath="$0_logs"
    saveFilePath=${saveFilePath/'.sh'/}
    if [ ! -d $saveFilePath ];then
        mkdir $saveFilePath
    fi
    echo "$saveFilePath/";
}


#----------执行入口----------------------------
while true;
do
    sleep $sheepTime;
    checkRunningProcess_main "tomcat" >> "$(getSaveLogsPath)tomcat_"$(date +%Y-%m-%d).log
    checkRunningProcess_main "jetty" >> "$(getSaveLogsPath)jetty_"$(date +%Y-%m-%d).log
done;

