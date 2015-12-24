hostname = node['hostname'].upcase

default['outsystems_platform']['database']['kind'] = 'mysql'
default['outsystems_platform']['database']['database'] = hostname
default['outsystems_platform']['database']['admin_user'] = hostname + '_OSADMIN'
default['outsystems_platform']['database']['runtime_user'] = hostname + '_OSRUNTIME'
default['outsystems_platform']['database']['log_user'] = hostname + '_OSLOG'

default['outsystems_platform']['session_database']['database'] =  hostname + '_SESSION'
default['outsystems_platform']['session_database']['session_user'] = hostname + '_OSSTATE'

default['outsystems_platform']['compiler_hostname'] = 'localhost'

