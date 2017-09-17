override['backup']['install_gem?'] = false
override['backup']['config_path'] = '/opt/backup'
override['backup']['model_path'] = '/opt/backup/models'

default['chef_rails_backups']['ruby_version'] = nil

default['chef_rails_backups']['postgresql']['username'] = nil
default['chef_rails_backups']['postgresql']['password'] = nil

default['chef_rails_backups']['aws_s3']['access_key_id'] = nil
default['chef_rails_backups']['aws_s3']['secret_access_key'] = nil
default['chef_rails_backups']['aws_s3']['storage_class'] = nil
default['chef_rails_backups']['aws_s3']['region'] = nil
default['chef_rails_backups']['aws_s3']['bucket'] = nil
default['chef_rails_backups']['aws_s3']['path'] = nil
default['chef_rails_backups']['aws_s3']['keep'] = nil

default['chef_rails_backups']['schedule']['minute'] = nil
default['chef_rails_backups']['schedule']['hour'] = nil
