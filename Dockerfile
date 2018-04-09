FROM centos:centos7

LABEL name="CentOS7 with JDK8 TOMCAT8"
MAINTAINER    Huc "306955302@qq.com"
ENV JAVA_VERSION 8
ENV JAVA_FOLDER_NAME jdk1.8.0_152
ENV JDK_HOME /usr/java/${JAVA_FOLDER_NAME}
ENV JAVA_HOME /usr/java/${JAVA_FOLDER_NAME}/jre
ENV JAVA_OPTS -Dfile.encoding=UTF-8

#拷贝JDK至容器内部
COPY jdk-8u152-linux-x64.tar.gz /tmp/jdk.tar.gz
RUN mkdir -p /usr/java
RUN tar -xzf /tmp/jdk.tar.gz -C /usr/java
RUN chown -R root:root ${JDK_HOME}
RUN echo "PATH=$PATH:/usr/java/${JAVA_FOLDER_NAME}/jre/bin:/usr/java/${JAVA_FOLDER_NAME}/bin" > /etc/profile.d/java
RUN rm /tmp/jdk.tar.gz

#RUN yum install wget -y
#RUN wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
COPY CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo
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
#可以先卸载一些不需要的软件 这样build出来的镜像会更小
RUN yum clean all 

#tomcat安装目录
ENV APACHE_TOMCAT_DOWNLOAD_URL https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.29/bin/apache-tomcat-8.5.29.tar.gz
ENV APACHE_TOMCAT_INSTALL_DIR /usr/local/apache-tomcat-8.5.29

#下载解压tomcat至指定目录
RUN curl \
	-L \
	-v \
	"${APACHE_TOMCAT_DOWNLOAD_URL}" \
	| tar -xz -C /usr/local
# 拷贝并新建一个tomcat临时配置文件
RUN cat ${APACHE_TOMCAT_INSTALL_DIR}/conf/server.xml | \
	sed 's/port="8080"/port="8080" useBodyEncodingForURI="true" URIEncoding="UTF-8" /' | \
	sed 's/appBase="webapps"/appBase="\/tomcat\/webapps"/' | \
	sed 's/directory="logs"/directory="\/tomcat\/logs"/' > \
	/tmp/server.xml
#替换TOMCAT配置文件
RUN cp /tmp/server.xml ${APACHE_TOMCAT_INSTALL_DIR}/conf/server.xml
#删除TOMCAT临时配置文件
RUN rm /tmp/server.xml
#删除tomcat无用的文件
RUN rm -rf   ${APACHE_TOMCAT_INSTALL_DIR}/bin/*.bat \
             ${APACHE_TOMCAT_INSTALL_DIR}/bin/tomcat-native.tar.gz \
             ${APACHE_TOMCAT_INSTALL_DIR}/webapps/*

# 创建持久化文件夹
RUN mkdir -p /tomcat/webapps/
RUN mkdir -p /tomcat/logs/
RUN mkdir -p /tomcat/attach/

#映射端口和目录
EXPOSE 8080 8009
VOLUME ["/tomcat/webapps", "/tomcat/logs", "/tomcat/attach"]
CMD ["/usr/local/apache-tomcat-8.5.29/bin/catalina.sh","run"]
