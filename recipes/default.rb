#
# Cookbook:: ELK_cookbook
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.
apt_update 'update ubuntu' do
  action :update
end

apt_package 'openjdk-8-jdk' do
  action :install
end

elasticsearch_user 'elasticsearch' do
  action :nothing
end

elasticsearch_install 'elasticsearch' do
  type :package
end

template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch.yml.erb'
end

service 'elasticsearch' do
  action [:enable, :start]
end

script 'logstash install' do
  interpreter 'bash'
  code <<-EOH
    wget https://download.elastic.co/logstash/logstash/packages/debian/logstash_2.3.4-1_all.deb
    dpkg -i logstash_2.3.4-1_all.deb
    sudo update-rc.d logstash defaults 97 8
    EOH
end

service 'logstash' do
  action :start
end

directory '/var/lib/logstash/private' do
  mode '777'
  action :create
end

execute 'create certificate and key' do
  command 'openssl req -config /etc/ssl/openssl.cnf -x509  -batch -nodes -newkey rsa:2048 -keyout /var/lib/logstash/private/logstash-forwarder.key -out /var/lib/logstash/private/logstash-forwarder.crt -subj /CN=192.168.10.120'
end

script 'append openssl config file' do
  interpreter 'bash'
  code <<-EOH
    echo "[v3_ca] subjectAltName = IP:192.168.10.120" >> /etc/ssl/openssl.conf
    EOH
end

template '/etc/logstash/conf.d/logstash.conf' do
  source 'logstash.conf.erb'
end

service 'logstash' do
  action :restart
end

package 'unzip' do
  action :install
end

script 'load filebeat index to elasticsearch' do
  interpreter 'bash'
  code <<-EOH
    curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip
    unzip beats-dashboards-1.1.0.zip
    cd beats-dashboards-1.1.0
    ./load.sh
    curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/ raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json
    curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json
    EOH
end

script 'install kibana' do
  interpreter 'bash'
  code <<-EOH
    cd /opt
    wget https://download.elastic.co/kibana/kibana/kibana-4.5.3-linux-x64.tar.gz
    tar -xzf kibana-4.5.3-linux-x64.tar.gz
    cd /opt/kibana-4.5.3-linux-x64/
    mv /opt/kibana-4.5.3-linux-x64 /opt/kibana
    EOH
end

file '/opt/kibana/config/kibana.yml' do
  action :delete
end

template '/opt/kibana/config/kibana.yml' do
  source 'kibana.yml.erb'
end

package 'ruby' do
  action :install
end

gem_package 'pleaserun' do
  action :install
end

execute 'create systemd daemon for kibana' do
  command 'pleaserun -p systemd -v default /opt/kibana/bin/kibana -p 5601 -H 0.0.0.0 -e http://localhost:9200'
end

service 'kibana' do
  action :start
end
