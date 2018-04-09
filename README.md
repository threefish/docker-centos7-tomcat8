# docker-centos7-oraclejdk8-tomcat8
### JDK
请自行准备 jdk-8u152-linux-x64.tar.gz 放在与Dockerfile同目录下
#### 构建镜像
```dockerfile
#我的文件 /home/ 目录下的
docker build -t tomcat8jdk8 /home/
```
### 创建容器
```bash
docker run -d -v /path/to/webapps:/tomcat/webapps -v /path/to/attach:/tomcat/attach -v /path/to/logs/:/tomcat/logs -p 80:8080 --name {你得容器名称} tomcat8jdk8:latest
```
