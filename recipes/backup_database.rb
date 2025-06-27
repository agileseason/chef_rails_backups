app = AppHelpers.new node['app']

rails_backup app.name + '_database' do
  app app

  postgresql node['chef_rails_backups']['postgresql']
  aws_s3 node['chef_rails_backups']['aws_s3']
  fog_options node['chef_rails_backups']['fog_options']

  schedule_minute node['chef_rails_backups']['schedule_database']['minute']
  schedule_hour node['chef_rails_backups']['schedule_database']['hour']

  backup_database true
  backup_directories false
end
