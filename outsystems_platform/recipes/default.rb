#
# Cookbook Name:: outsytems_platform
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

include_recipe 'outsystems_platform::prerequisites'

if platform?('centos')  

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
		source "#{node['outsystems_platform']['database']['kind']}.hsconf.erb"
		variables({
			:outsystems_platform => node['outsystems_platform']
		})
	end

	bash 'run configuration tool' do
		code <<-EOH
		/opt/outsystems/platform/configurationtool.sh /silent /upgradeinstall /scinstall
		EOH
	end

elsif platform?('windows')

	windows_package 'OutSystems Development Environment 9.1' do
		source 'https://outsystemssupport.s3.amazonaws.com/public/chef/DevelopmentEnvironment.exe'
		package_name 'OutSystems Development Environment 9.1'
		options '/S'
		action :install
	end

	windows_package 'OutSystems Platform Server' do
		source 'https://outsystemssupport.s3.amazonaws.com/public/chef/PlatformServer.exe'
		package_name 'OutSystems Platform Server'
		installer_type :custom
		options '/S'
		action :install
	end

	template 'C:\Program Files\OutSystems\Platform Server\server.hsconf' do
		source "#{node['outsystems_platform']['database']['kind']}.hsconf.erb"
		variables({
			:outsystems_platform => node['outsystems_platform']
		})
	end

	execute 'run configuration tool' do 
		command "\"C:\\Program Files\\OutSystems\\Platform Server\\ConfigurationTool.exe\" /Silent /UpgradeInstall /SCInstall /RebuildSession #{node['outsystems_platform']['session_database']['session_user']} #{node['outsystems_platform']['session_database']['session_password']}"
	end


	iis_pool 'OutSystemsApplications' do
		rapid_fail_protection false
		private_mem   (node['memory']['total'][0..-3].to_i * 0.7).to_i
		action :config
	end

	iis_pool 'ServiceCenter' do
		runtime_version "4.0"
		pipeline_mode :Classic
		recycle_after_time "00:00:00"
		rapid_fail_protection false
		action :add
	end

	iis_app "/ServiceCenter" do
		application_pool "ServiceCenter"
		path "/ServiceCenter"
		site_name "Default Web Site"
		action :config
	end

	directory 'C:\Program Files\OutSystems\Platform Server\logs' do
		rights :modify, 'IIS_IUSRS'
	end

	powershell_script 'Configure ISAPI' do
		code <<-EOH
		Import-Module WebAdministration

		if((Get-WebConfiguration -Filter /system.webServer/isapiFilters/filter |
			where { $_.path -eq "C:\\Program Files\\OutSystems\\Platform Server\\OsISAPIFilterx64.dll" }) `
			-eq $null) {

		Add-WebConfiguration -Filter  /system.webServer/isapiFilters  `
			-Value @{
				name = "OutSystems ISAPI Filter";
				path = "C:\\Program Files\\OutSystems\\Platform Server\\OsISAPIFilterx64.dll"
			} `
			-PSPath 'IIS:\';
		}
		EOH
	end

	iis_site 'Default Web Site' do
		application_pool 'OutSystemsApplications'
		action :config
	end

	# not very fond of unconditional IIS reset here, but not sure who should notify.
	execute 'iisreset'

end