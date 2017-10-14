FROM bpatterson/centos7-jdk8:latest

LABEL name="CentOS7 with Apache Tomcat 8"

RUN yum install wget -y
RUN wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo

#生成缓存
RUN yum update -y && yum makecache
#########################################中文乱码处理################################################
#时区设置
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#安装中文支持   
RUN yum -y install kde-l10n-Chinese && yum -y reinstall glibc-common 
#配置显示中文 
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 
#设置环境变量 
ENV LC_ALL zh_CN.utf8 
RUN echo "export LC_ALL=zh_CN.utf8" >> /etc/profile
RUN yum clean all 

ENV APACHE_TOMCAT_DOWNLOAD_URL http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz
ENV APACHE_TOMCAT_INSTALL_DIR /usr/local/apache-tomcat-8.5.23
ENV JAVA_OPTS -Dfile.encoding=UTF-8

RUN curl \
	-L \
	-v \
	"${APACHE_TOMCAT_DOWNLOAD_URL}" \
	| tar -xz -C /usr/local

# 修改TOMCAT配置文件
RUN cat ${APACHE_TOMCAT_INSTALL_DIR}/conf/server.xml | \
	sed 's/port="8080"/port="8080" useBodyEncodingForURI="true" URIEncoding="UTF-8" /' | \
	sed 's/appBase="webapps"/appBase="\/tomcat\/webapps"/' | \
	sed 's/directory="logs"/directory="\/tomcat\/logs"/' > \
	/tmp/server.xml

RUN cp /tmp/server.xml ${APACHE_TOMCAT_INSTALL_DIR}/conf/server.xml
RUN rm /tmp/server.xml
RUN rm -rf   ${CATALINA_HOME}/bin/*.bat \
             ${CATALINA_HOME}/bin/tomcat-native.tar.gz \
             ${CATALINA_HOME}/webapps/* 


RUN mkdir -p /tomcat/webapps/
RUN mkdir -p /tomcat/logs/

EXPOSE 8080 8009
VOLUME ["/tomcat/webapps", "/tomcat/logs"]
CMD ["${APACHE_TOMCAT_INSTALL_DIR}/bin/catalina.sh","run"]
