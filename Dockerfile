FROM ubuntu:16.04

# Setup environment
ENV DEBIAN_FRONTEND noninteractive

# Install
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget curl bash-completion && \
  rm -rf /var/lib/apt/lists/*

#Install Java
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository ppa:webupd8team/java && \
  apt-get update -y && \
  apt-get install oracle-java8-installer -y

ENV JAVA_HOME="/usr/lib/jvm/java-8-oracle" 

#Install Tomcat
RUN useradd -r tomcat9 --shell /bin/false
ADD http://apache.mirror.rafal.ca/tomcat/tomcat-9/v9.0.0.M26/bin/apache-tomcat-9.0.0.M26.tar.gz /opt/
RUN cd /opt/ && \
  tar -zxf apache-tomcat-9.0.0.M26.tar.gz && \
  ln -s apache-tomcat-9.0.0.M26 tomcat-latest && \
  rm apache-tomcat-9.0.0.M26.tar.gz && \
  chown -hR tomcat9: tomcat-latest apache-tomcat-9.0.0.M26

#Install SSH and supervisor
RUN apt-get install -y openssh-server openssh-client passwd supervisor git && \
  mkdir -p /var/run/sshd /var/run/sshd /var/log/supervisor

COPY tomcat.conf /etc/supervisor/conf.d/

CMD ["/usr/bin/supervisord", "-n"]

RUN ln -s /opt/app/apache-oltu-oauth2-demo /opt/tomcat-latest/webapps/apache-oltu-oauth2-demo
RUN ln -s /opt/app/apache-oltu-oauth2-demo.war /opt/tomcat-latest/webapps/apache-oltu-oauth2-demo.war

WORKDIR /opt/auth-server
 

