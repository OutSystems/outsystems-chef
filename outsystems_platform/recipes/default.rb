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
		source 'mysql.hsconf.erb'
		variables({
			:outsystems_platform => node['outsystems_platform']
		})
	end

	bash 'run configuration tool' do
		code <<-EOH
		/opt/outsystems/platform/configurationtool.sh /silent /setupinstall /scinstall
		EOH
	end

elsif platform?('windows')

# do stuff

end