app = AppHelpers.new node['app']

rails_backup app.name do
  app app

  postgresql node['chef_rails_backups']['postgresql']
  aws_s3 node['chef_rails_backups']['aws_s3']
  fog_options node['chef_rails_backups']['fog_options']

  schedule_minute node['chef_rails_backups']['schedule']['minute']
  schedule_hour node['chef_rails_backups']['schedule']['hour']

  backup_database true
  backup_directories node['chef_rails_backups']['directories']
end
