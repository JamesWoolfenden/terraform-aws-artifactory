#!/bin/bash

yum update -y
yum install -y java-1.8.0>> /tmp/yum-java8.log
alternatives --force --set java /usr/lib/jvm/java-1.8.0-openjdk.x86_64/bin/java
yum -y remove java-1.7.0-openjdk>> /tmp/yum-java7.log 2>&1

##Install Artifactory
wget https://bintray.com/jfrog/artifactory-pro-rpms/rpm -O bintray-jfrog-artifactory-pro-rpms.repo
mv bintray-jfrog-artifactory-pro-rpms.repo /etc/yum.repos.d/
sleep 10
yum install -y jfrog-artifactory-pro>> /tmp/yum-artifactory.log 2>&1
amazon-linux-extras install nginx1>> /tmp/yum-nginx.log 2>&1

# not sure this driver is still required as its not on bintray any more
mkdir -p /opt/jfrog/artifactory/tomcat/lib
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/mysql-connector-java-5.1.38.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar

cat <<EOF >/var/opt/jfrog/artifactory/etc/binarystore.xml
<config version="2">
    <chain> <!--template="cluster-s3"-->
        <provider id="cache-fs-eventual-s3" type="cache-fs">
            <provider id="sharding-cluster-eventual-s3" type="sharding-cluster">
                <sub-provider id="eventual-cluster-s3" type="eventual-cluster">
                    <provider id="retry-s3" type="retry">
                        <provider id="s3" type="s3"/>
                    </provider>
                </sub-provider>
                <dynamic-provider id="remote-s3" type="remote"/>
            </provider>
        </provider>
    </chain>

    <provider id="sharding-cluster-eventual-s3" type="sharding-cluster">
        <readBehavior>crossNetworkStrategy</readBehavior>
        <writeBehavior>crossNetworkStrategy</writeBehavior>
        <redundancy>2</redundancy>
        <property name="zones" value="local,remote"/>
    </provider>

    <provider id="remote-s3" type="remote">
        <zone>remote</zone>
    </provider>

    <provider id="eventual-cluster-s3" type="eventual-cluster">
        <zone>local</zone>
    </provider>
    <provider id="s3" type="s3">
       <endpoint>s3.dualstack.${s3_bucket_region}.amazonaws.com</endpoint>
       <bucketName>${s3_bucket_name}</bucketName>
    </provider>
</config>
EOF

cat <<EOF >/var/opt/jfrog/artifactory/etc/db.properties
  type=mysql
  driver=com.mysql.jdbc.Driver
  url=jdbc:mysql://${db_url}/${db_name}??characterEncoding=UTF-8&elideSetAutoCommits=true
  username=${db_user}
  password=${db_password}
EOF

mkdir -p /var/opt/jfrog/artifactory/etc/security

cat <<EOF >/var/opt/jfrog/artifactory/etc/security/master.key
${master_key}
EOF

cat <<EOF >/etc/nginx/nginx.conf
  #user  nobody;
  worker_processes  1;
  error_log  /var/log/nginx/error.log  info;
  #pid        logs/nginx.pid;
  events {
    worker_connections  1024;
  }

  http {
    include       mime.types;
    variables_hash_max_size 1024;
    variables_hash_bucket_size 64;
    server_names_hash_max_size 4096;
    server_names_hash_bucket_size 128;
    types_hash_max_size 2048;
    types_hash_bucket_size 64;
    proxy_read_timeout 2400s;
    client_header_timeout 2400s;
    client_body_timeout 2400s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 2400s;
    proxy_buffer_size 32k;
    proxy_buffers 40 32k;
    proxy_busy_buffers_size 64k;
    proxy_temp_file_write_size 250m;
    proxy_http_version 1.1;
    client_body_buffer_size 128k;

    include    /etc/nginx/conf.d/*.conf;
    default_type  application/octet-stream;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    '\$status \$body_bytes_sent "\$http_referer" '
    '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    #tcp_nopush     on;
    #keepalive_timeout  0;
    keepalive_timeout  65;
    }
EOF

echo "artifactory.ping.allowUnauthenticated=true" >> /var/opt/jfrog/artifactory/etc/artifactory.system.properties
echo "export JAVA_OPTIONS=\"${EXTRA_JAVA_OPTS}\"" >> /var/opt/jfrog/artifactory/etc/default
sed -i -e "s/art1/art-$(date +%s$RANDOM)/" /var/opt/jfrog/artifactory/etc/ha-node.properties
sed -i -e "s/127.0.0.1/$(curl http://169.254.169.254/latest/meta-data/public-ipv4)/" /var/opt/jfrog/artifactory/etc/ha-node.properties
sed -i -e "s/172.25.0.3/$(curl http://169.254.169.254/latest/meta-data/local-ipv4)/" /var/opt/jfrog/artifactory/etc/ha-node.properties
chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/* && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/*  && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/security
service artifactory start
service nginx start
