#
# Cookbook Name:: outsytems_platform
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

package [ 'bash', 'openssh-clients', 'iptables', 'zip', 'unzip', 'dos2unix', 'patch' ]

remote_file '/tmp/apache-ant-1.9.6-bin.zip' do 
	source 'http://mirrors.fe.up.pt/pub/apache/ant/binaries/apache-ant-1.9.6-bin.zip'
	action :create
	not_if { ::File.directory?('/opt/apache-ant-1.9.6/')}
end

remote_file '/tmp/wildfly-8.2.0.Final.zip' do
	source 'http://download.jboss.org/wildfly/8.2.0.Final/wildfly-8.2.0.Final.zip'
	action :create
	not_if { ::File.directory?('/opt/wildfly-8.2.0.Final/') } 
end

remote_file '/tmp/jdk-8u66-linux-x64.rpm' do 
	source 'file:///media/sf_VBoxShare/jdk-8u66-linux-x64.rpm'
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
file '/etc/yum.repos.d/outsystems.repo' do
	content <<-EOH
[outsystems]
name=OutSystems
baseurl=http://yum.outsystems.net/9.1/noarch
enabled=1
gpgcheck=1
gpgkey=http://yum.outsystems.net/9.1/noarch/OUTSYSTEMS-RPM-GPG-KEY-SUPPORT
	EOH
	action :create
end

package [ 'outsystems-agileplatform-wildfly8', 'outsystems-agileplatform', 'outsystems-agileplatform-libs' ]

remote_file '/opt/outsystems/platform/jce_policy-8.zip' do
	source 'file:///media/sf_VBoxShare/jce_policy-8.zip'
	action :create
end

template '/etc/outsystems/server.hsconf' do
	source 'mysql.hsconf.erb'
	variables({
		:outsystems_platform => node['outsystems_platform']
	})
end

