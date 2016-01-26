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
			:major_version => node['outsystems_platform']['major_version']
		})
	end

	package [ 'outsystems-agileplatform-wildfly8', 'outsystems-agileplatform', 'outsystems-agileplatform-libs' ]

	remote_file '/opt/outsystems/platform/jce_policy-8.zip' do
		source "#{node['outsystems_platform']['third_party_nonfree_url']}/java/jce_policy-8.zip"
		action :create
		checksum 'f3020a3922efd6626c2fff45695d527f34a8020e938a49292561f18ad1320b59'
	end

	template '/etc/outsystems/server.hsconf' do
		source "#{node['outsystems_platform']['database']['kind']}.hsconf.erb"
		variables({
			:outsystems_platform => node['outsystems_platform']
		})
	end

	if node['outsystems_platform']['install_sap']

		remote_file '/opt/outsystems/platform/thirdparty/lib/sapjco3.jar' do
			source "#{node['outsystems_platform']['third_party_nonfree_url']}/sap/sapjco3.jar"
			action :create
		end

		remote_file '/opt/outsystems/platform/thirdparty/lib/libsapjco3.so' do
			source "#{node['outsystems_platform']['third_party_nonfree_url']}/sap/libsapjco3.so"
			action :create
		end

	end

	bash 'run configuration tool' do
		code <<-EOH
		/opt/outsystems/platform/configurationtool.sh /silent /upgradeinstall /scinstall
		EOH
	end

	bash 'install system components' do
		code <<-EOH
		/opt/outsystems/platform/osptool.sh /opt/outsystems/platform/System_Components.osp localhost admin admin
		EOH
	end


elsif platform?('windows')

	windows_package "OutSystems Development Environment #{node['outsystems_platform']['major_version']}" do
		source "#{node['outsystems_platform']['outsystems_platform_url']}/#{node['outsystems_platform']['major_version']}/#{node['outsystems_platform']['version']}/DevelopmentEnvironment.exe"
		package_name "OutSystems Development Environment #{node['outsystems_platform']['major_version']}"
		options '/S'
		action :install
	end

	windows_package 'OutSystems Platform Server' do
		source "#{node['outsystems_platform']['outsystems_platform_url']}/#{node['outsystems_platform']['major_version']}/#{node['outsystems_platform']['version']}/PlatformServer.exe"
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

	if node['outsystems_platform']['install_sap']

		remote_file 'C:\Program Files\OutSystems\Platform Server\thirdparty\lib\sapnco.dll' do
			source "#{node['outsystems_platform']['third_party_nonfree_url']}/sap/sapnco.dll"
			action :create
		end

		remote_file 'C:\Program Files\OutSystems\Platform Server\thirdparty\lib\sapnco_utils.dll' do
			source "#{node['outsystems_platform']['third_party_nonfree_url']}/sap/sapnco_utils.dll"
			action :create
		end

		remote_file "#{ENV['WINDIR']}\\system32\\libicudecnumber.dll" do
			source "#{node['outsystems_platform']['third_party_nonfree_url']}/sap/libicudecnumber.dll"
			action :create
		end

		remote_file "#{ENV['WINDIR']}\\system32\\rscp4n.dll" do
			source "#{node['outsystems_platform']['third_party_nonfree_url']}/sap/rscp4n.dll"
			action :create
		end

	end

	execute 'run configuration tool' do 
		command "\"C:\\Program Files\\OutSystems\\Platform Server\\ConfigurationTool.exe\" /Silent /UpgradeInstall /SCInstall /RebuildSession #{node['outsystems_platform']['session_database']['session_user']} #{node['outsystems_platform']['session_database']['session_password']}"
	end

	iis_pool 'OutSystemsApplications' do
		rapid_fail_protection false
		private_mem   (node['memory']['total'][0..-3].to_i * 0.7).to_i
		idle_timeout "00:00:00"
		action :config
	end

	iis_pool 'ServiceCenter' do
		runtime_version "4.0"
		pipeline_mode :Classic
		recycle_after_time "00:00:00"
		idle_timeout "00:00:00"
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

	execute 'install system components' do 
		command "\"C:\\Program Files\\Common Files\\OutSystems\\#{node['outsystems_platform']['major_version']}\\OSPTool.exe\" \"C:\\Program Files\\OutSystems\\Platform Server\\System_Components.osp\" localhost admin admin"
	end

end