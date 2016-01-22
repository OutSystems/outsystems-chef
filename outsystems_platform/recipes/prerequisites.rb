#
# Cookbook Name:: outsytems_platform
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

if platform?('centos')

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

	remote_file '/tmp/jdk-8u72-linux-x64.rpm' do 
		source 'https://outsystemssupport.s3.amazonaws.com/public/chef/jdk-8u72-linux-x64.rpm'
		action :create
		not_if "rpm -q jdk1.8.0_72"
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
		source '/tmp/jdk-8u72-linux-x64.rpm'
		action :install
		not_if "rpm -q jdk1.8.0_72"
	end

	# while there is no harm is executing this
	# how do I avoid it if not necessary?
	# is there a chef package to manage this ?
	bash 'java alternatives' do
		code <<-EOH
		alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_72/bin/java 16999
		alternatives --install /usr/java/java-1.8.0 java_sdk_1.8.0 /usr/java/jdk1.8.0_72/ 16999
		alternatives --set java /usr/java/jdk1.8.0_72/bin/java
		alternatives --set java_sdk_1.8.0 /usr/java/jdk1.8.0_72/
		EOH
	end

	# this is a bit rough, but it doesnt seem like chef has a way to manage only a portion of a file
	bash 'inotify fix' do
		code <<-EOH
		echo 2048 > /proc/sys/fs/inotify/max_user_instances
		echo 524288 > /proc/sys/fs/inotify/max_user_watches
		echo '# OUTSYSTEMS ' >> /etc/sysctl.conf
		echo fs.inotify.max_user_instances=2048 >> /etc/sysctl.conf
		echo fs.inotify.max_user_watches=524288 >> /etc/sysctl.conf
		EOH
		not_if "grep OUTSYSTEMS /etc/sysctl.conf"
	end

elsif platform?('windows')


	features_to_install = [ 
	   ['NetFx3', true], 
	   ['NetFx3ServerFeatures', false],
	   ['MSMQ-Server', true ],
	   ['NetFx4ServerFeatures', false],
	   ['NetFx4', true],
	   ['WAS-WindowsActivationService', false],
	   ['WAS-ProcessModel', true],
	   ['WAS-NetFxEnvironment', true],
	   ['WAS-ConfigurationAPI', false],
	   ['Application-Server', true],
	   ['AS-NET-Framework',false],
	   ['IIS-WebServerRole', false],
	   ['IIS-WebServer', false],
	   ['IIS-CommonHttpFeatures', false],
	   ['IIS-DefaultDocument', false],
	   ['IIS-DirectoryBrowsing',  false],
	   ['IIS-HttpErrors', false],
	   ['IIS-StaticContent', false],
	   ['IIS-HealthAndDiagnostics', false],
	   ['IIS-HttpLogging', false],
	   ['IIS-RequestMonitor', false],
	   ['IIS-Performance', true],
	   ['IIS-HttpCompressionDynamic', false],
	   ['IIS-HttpCompressionStatic', false],
	   ['IIS-Security', false],
	   ['IIS-RequestFiltering', true],
	   ['IIS-WindowsAuthentication', false],
	   ['IIS-ApplicationDevelopment', false],
	   ['IIS-NetFxExtensibility', false],
	   ['IIS-NetFxExtensibility45', false],
	   ['IIS-ISAPIFilter', false],
	   ['IIS-ISAPIExtensions', false],
	   ['IIS-ASPNET', false],
	   ['IIS-ASPNET45', false],
	   ['IIS-WebServerManagementTools', false],
	   ['IIS-ManagementConsole', true],
	   ['IIS-IIS6ManagementCompatibility', false ],
	   ['IIS-Metabase', false ]
	]


	features_to_install.each do |feature,all|
		windows_feature feature do
			all all
		end
	end


	registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSMQ\Parameters\Setup' do
		recursive true
		values [{ name: 'AlwaysWithoutDS', type: :dword, data: 1 }]
		action :create_if_missing
	end

	service 'WSearch' do # Windows Search
		action [:stop, :disable]
		only_if { defined?(::Win32) && ::Win32::Service.exists?('WSearch') }
	end

	service 'Winmgmt' do # Windows Management Instrumentation
		action [:enable, :start]
	end


    registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application' do
      recursive true
      values [
        { name: 'MaxSize', type: :dword, data: 1_400_000 },
        { name: 'Retention', type: :dword, data: 0 }
      ]
      action :create_if_missing
    end

    registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System' do
      recursive true
      values [
        { name: 'MaxSize', type: :dword, data: 1_400_000 },
        { name: 'Retention', type: :dword, data: 0 }
      ]
      action :create_if_missing
    end

    registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Security' do
      recursive true
      values [
        { name: 'MaxSize', type: :dword, data: 1_400_000 },
        { name: 'Retention', type: :dword, data: 0 }
      ]
      action :create_if_missing
    end


end