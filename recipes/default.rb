#
# Cookbook Name:: chef_rails_backups
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

app = AppHelpers.new node['app']

node.override['backup']['install_gem?'] = false
node.override['backup']['config_path'] = '/opt/backup'
node.override['backup']['model_path'] = '/opt/backup/models'

node.override['backup']['user'] = app.user
node.override['backup']['group'] = app.group

include_recipe 'backup'

# NOTE: disabled schedules must be removed from /etc/cron.d/ manually
if node['chef_rails_backups']['schedule']['enabled']
  include_recipe 'chef_rails_backups::backup_all'
else
  if node['chef_rails_backups']['schedule_database']['enabled']
    include_recipe 'chef_rails_backups::backup_database'
  end

  if node['chef_rails_backups']['schedule_directories']['enabled']
    include_recipe 'chef_rails_backups::backup_directories'
  end
end
