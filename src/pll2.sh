##/bin/sh
 # 使用curl检查网页是否可以正常访问，


 #-------------请定义如下参数----------------------

 #请求路径
 path="https://api.vi-ni.com/webapi/v1/card/117429";

 #发送邮件给谁
 emails=("2531868871@qq.com" "chuxiong.ren@chenghong.cc" "1270040457@qq.com" "guoyu@chenghong.cc");

 #请求间隔(秒)
 sleepTime=60;

 #检查请求执行失败时需要运行的的方法,请在下面的方法体中写你要执行的脚本
 fault_run()
 {
 	echo "fault_run..."
 	for email in ${emails[@]};
 	do
 		#发送邮件
 		echo "sendMail To=$email"
 		viewPath=${path/http:/ };
 		viewPath=${path/https:/};
 		echo "$(mydate), $viewPath, check request fault." | mail -s "project_check_request" $email;
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
         #if curl -s -I --connect-timeout 5 --max-time 10 http://localhost:$1/; then
         if curl -s -I --retry 3 --connect-timeout 5 --max-time 10 "$path" | grep -q '200 OK';

 	then
         	echo "$(mydate) request path=$path OK"
         else
 		echo "$(mydate) request path=$path FAULT"
 		fault_run
         fi
 	echo "$(mydate) request check end"
 	echo
 };


 # 每隔一分钟检查一次网页是否正常
 saveLogPath="check_request_logs/"
 check_loop()
 {
         while true;
         do

 		if [ ! -d "$saveLogPath" ]; then
 			mkdir "$saveLogPath"
 		fi

                 check_once >> "$saveLogPath"$(date +%Y-%m-%d).log

 		sleep $sleepTime
         done
 };


check_loop;




set from=guoyu@chenghong.cc
set smtp=smtp.exmail.qq.com
set smtp-auth-user=guoyu@chenghong.cc
set smtp-auth-password=chenghong124536
set smtp-auth=login
