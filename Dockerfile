FROM tomcat:8.5.37-jre8

LABEL name="tomcat8jre8"

MAINTAINER Huc "huchuc@vip.qq.com"
#设置环境变量
ENV JAVA_OPTS -Dfile.encoding=UTF-8
#设置文件系统
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
#设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV APACHE_TOMCAT_DIR /usr/local/tomcat/
#删除tomcat无用的文件
RUN rm -rf   ${APACHE_TOMCAT_DIR}/webapps/docs \
             ${APACHE_TOMCAT_DIR}/webapps/examples \
             ${APACHE_TOMCAT_DIR}/webapps/host-manager \
             ${APACHE_TOMCAT_DIR}/webapps/manager
# 创建附件持久化目录
RUN mkdir -p /usr/local/tomcat/attach
EXPOSE 8080
#映射目录
VOLUME ["/usr/local/tomcat/webapps", "/usr/local/tomcat/logs", "/usr/local/tomcat/attach"]
CMD ["catalina.sh", "run"]
