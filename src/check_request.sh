#/bin/sh

#check_request.sh
#使用curl检查网页是否可以正常访问.mailx发送邮件
#请确认你的服务器上安装了这两个软件,并且mailx配置好了发信人,邮箱发送登录服务器
#请求日志写入在当前脚本所在的相对路径 "check_request_logs/日期.log"
#脚本编写:上海澄泓信息科技,郭宇,于2016/02/21

#请把下面参数的定义在安装mailx之后,添加到/etc/mail.rc(或者nail)中去
#澄泓公司邮箱
#set from=guoyu@chenghong.cc
#set smtp=smtp.exmail.qq.com
#set smtp-auth-user=guoyu@chenghong.cc
#set smtp-auth-password=chenghong124536
#set smtp-auth=login


#-------------请定义如下参数-------------

#请求路径,可以定义多个,在括号中用空格格开
paths=("http://127.0.0.1:8090/webapi/v1/store/parent/12" "http://127.0.0.1:8080/admin/login");

#发送邮件给谁
emails=("2531868871@qq.com" "chuxiong.ren@chenghong.cc" "1270040457@qq.com" "guoyu@chenghong.cc");

#请求间隔(秒)
sleepTime=90;

#提示语,主题
subject="V-Card 正式环境,网络请求访问出错"

#检查请求执行失败时需要运行的方法
#请在下面的方法体中写你要执行的脚本,比如需要重启tomcat服务器的操作,请写在此方法体中
#注意:如果没有必要,不用修改此方法
fault_run()
{
        echo "fault_run..."
        local emailBody="$(mydate), $path, $subject."
        echo $emailBody
        for email in ${emails[@]};
        do
                #发送邮件
                echo "sendMail To=$email"
                echo $emailBody | mail -s "$subject" $email;
        done
};



#--------下面的方法都不要动-----------

mydate()
{
 date "+%Y-%m-%d %H:%M:%S"
};

check_once()
{
    echo "$(mydate) request check start"
    if curl -s -i --retry 3 --connect-timeout 5 --max-time 10 "$path" | grep -q '200 OK';
        then
            echo "$(mydate) request path=$path OK"
        else
            echo "$(mydate) request path=$path FAULT"
            fault_run
    fi
	echo "$(mydate) request check end"
	echo
};

#获得日志保存目录
getSaveLogsPath(){
	local saveFilePath="$0_logs"
	saveFilePath=${saveFilePath/'.sh'/}
	if [ ! -d $saveFilePath ];then
		mkdir $saveFilePath
	fi
	echo "$saveFilePath/";
}

# 每隔一分钟检查一次网页是否正常
check_loop()
{
        while true;
        do
            sleep $sleepTime;

            for i in ${paths[@]};
            do
                path=$i
                check_once >> "$(getSaveLogsPath)"$(date +%Y-%m-%d).log
            done;

        done
};


check_loop


#the end
