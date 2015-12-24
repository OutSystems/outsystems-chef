#
# Cookbook Name:: outsytems_platform
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

package [ 'bash', 'openssh-clients', 'iptables', 'zip', 'unzip', 'dos2unix', 'patch' ]

service 'iptables' do
	action [ :enable, :start ]
end

remote_file '/tmp/apache-ant-1.9.6-bin.zip' do 
	source 'https://outsystemssupport.s3.amazonaws.com/public/chef/apache-ant-1.9.6-bin.zip'
	action :create
	not_if { ::File.directory?('/opt/apache-ant-1.9.6/')}
end

remote_file '/tmp/wildfly-8.2.0.Final.zip' do
	source 'https://outsystemssupport.s3.amazonaws.com/public/chef/wildfly-8.2.0.Final.zip'
	action :create
	not_if { ::File.directory?('/opt/wildfly-8.2.0.Final/') } 
end

remote_file '/tmp/jdk-8u66-linux-x64.rpm' do 
	source 'https://outsystemssupport.s3.amazonaws.com/public/chef/jdk-8u66-linux-x64.rpm'
	action :create
	not_if "rpm -q jdk1.8.0_66"
end


bash 'install ant' do
	code <<-EOH
	unzip -d /opt/ /tmp/apache-ant-1.9.6-bin.zip
	EOH
	not_if { ::File.directory?('/opt/apache-ant-1.9.6/') }
end

bash 'install wildfly' do
	code <<-EOH
		unzip -d /opt/ /tmp/wildfly-8.2.0.Final.zip
	EOH
	not_if { ::File.directory?('/opt/wildfly-8.2.0.Final/') } 
end 

package 'oracle java' do
	source '/tmp/jdk-8u66-linux-x64.rpm'
	action :install
	not_if "rpm -q jdk1.8.0_66"
end

# while there is no harm is executing this
# how do I avoid it if not necessary?
# is there a chef package to manage this ?
bash 'java alternatives' do
	code <<-EOH
	alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_66/bin/java 16999
	alternatives --install /usr/java/java-1.8.0 java_sdk_1.8.0 /usr/java/jdk1.8.0_66/ 16999
	alternatives --set java /usr/java/jdk1.8.0_66/bin/java
	alternatives --set java_sdk_1.8.0 /usr/java/jdk1.8.0_66/
	EOH
end

# this is a bit rough, but it doesnt seem like chef has a way to manage only a portion of a file
bash 'inotify fix' do
	code <<-EOH
	echo 2048 > /proc/sys/fs/inotify/max_user_instances
	echo '# OUTSYSTEMS ' >> /etc/sysctl.conf
	echo fs.inotify.max_user_instances=2048 >> /etc/sysctl.conf
	EOH
	not_if "grep OUTSYSTEMS /etc/sysctl.conf"
end

# this does the same as installing the outsystems-repo package
template '/etc/yum.repos.d/outsystems.repo' do
	source 'outsystems.repo.erb'
	variables({
		:major_version => '9.1'
	})
end

package [ 'outsystems-agileplatform-wildfly8', 'outsystems-agileplatform', 'outsystems-agileplatform-libs' ]

remote_file '/opt/outsystems/platform/jce_policy-8.zip' do
	source 'https://outsystemssupport.s3.amazonaws.com/public/chef/jce_policy-8.zip'
	action :create
	checksum 'f3020a3922efd6626c2fff45695d527f34a8020e938a49292561f18ad1320b59'
end

template '/etc/outsystems/server.hsconf' do
	source 'mysql.hsconf.erb'
	variables({
		:outsystems_platform => node['outsystems_platform']
	})
end

