app = AppHelpers.new node['app']

rails_backup app.name + '_directories' do
  app app

  postgresql node['chef_rails_backups']['postgresql']
  aws_s3 node['chef_rails_backups']['aws_s3']

  schedule_minute node['chef_rails_backups']['schedule_directories']['minute']
  schedule_hour node['chef_rails_backups']['schedule_directories']['hour']

  backup_database false
  backup_directories node['chef_rails_backups']['directories']
end
