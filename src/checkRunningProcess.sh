#!/bin/bash

#checkRunningProcess.sh
#输入服务名称,如果存在 该服务已停止,并且 "服务名 + Restart" 文件存在时,就把该服务重启,并且发送给相关人员
#编写人:上海澄泓信息科技,郭宇,2016/01/22

#重启时,发送邮件给谁
emails=("2531868871@qq.com" "chuxiong.ren@chenghong.cc" "1270040457@qq.com" "guoyu@chenghong.cc");

#提示语,主题
subject="(测试)服务器已经自动重启了"

#发送邮件
mySendMail(){
    local emailBody="$(mydate), 监控shell脚本检测到 $serviceName 服务器非正常关机了,所以把 $serviceName 服务器重新打开了."
    echo $emailBody
    for email in ${emails[@]};
    do
        echo "sendMail To=$email"
        echo $emailBody | mail -s "$serviceName $subject" $email;
    done
}

mydate()
{
 date "+%Y-%m-%d %H:%M:%S"
};

#检查
checkRunningProcess_main(){
    echo "1111111"
    while true;
    do
        local ps_out="ps -ef | grep $serviceName | grep -v grep | wc -l"
        if [ "$ps_out" != 0 ];then
            echo "$serviceName Running"
        else
            echo "$serviceName Not Running"
            if [ -f "$serviceNameRestart" ];then
                sudo service "$serviceName" stop;
                sudo service "$serviceName" start;
                $(mySendMail);
            fi
        fi
        sleep 60;
    done;
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

echo "333333"
serviceName="tomcat"
$(checkRunningProcess_main)
# >> "$(getSaveLogsPath)$serviceName_"$(date +%Y-%m-%d).log

echo "44444"

serviceName="jetty"
&"$(checkRunningProcess_main)" >> "$(getSaveLogsPath)$serviceName_"$(date +%Y-%m-%d).log &

