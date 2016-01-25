hostname = node['hostname'].upcase

# database settings
default['outsystems_platform']['database']['database'] = hostname
default['outsystems_platform']['database']['admin_user'] = hostname + '_OSADMIN'
default['outsystems_platform']['database']['runtime_user'] = hostname + '_OSRUNTIME'
default['outsystems_platform']['database']['log_user'] = hostname + '_OSLOG'

# only used by Oracle
default['outsystems_platform']['database']['port'] = 1521
default['outsystems_platform']['database']['admin_tablespace'] = hostname + '_OSSYS'
default['outsystems_platform']['database']['runtime_tablespace'] = hostname + '_OSUSR'
default['outsystems_platform']['database']['log_tablespace'] = hostname + '_OSLOG'
default['outsystems_platform']['database']['index_tablespace'] = hostname + '_OSIDX'

# session database settings
default['outsystems_platform']['session_database']['database'] =  hostname + '_SESSION'
default['outsystems_platform']['session_database']['session_user'] = hostname + '_OSSTATE'

# only used by Oracle
default['outsystems_platform']['session_database']['port'] =  1521
default['outsystems_platform']['session_database']['session_tablespace'] = hostname + '_OSSTATE'


default['outsystems_platform']['compiler_hostname'] = hostname

# change these to host the binaries in your own infrastructure
default['outsystems_platform']['outsystems_platform_url'] = 'https://outsystemssupport.s3.amazonaws.com/public/chef/platform'
default['outsystems_platform']['third_party_free_url'] = 'https://outsystemssupport.s3.amazonaws.com/public/chef/thirdparty/free'

# which platform version you want to install ?
# currently only tested for 9.1
default['outsystems_platform']['major_version'] = '9.1'
default['outsystems_platform']['version'] = 'latest'
