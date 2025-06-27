# frozen_string_literal: true

default['chef_rails_backups']['postgresql']['database'] = nil
default['chef_rails_backups']['postgresql']['username'] = nil
default['chef_rails_backups']['postgresql']['password'] = nil
default['chef_rails_backups']['postgresql']['host'] = 'localhost'

default['chef_rails_backups']['aws_s3']['access_key_id'] = nil
default['chef_rails_backups']['aws_s3']['secret_access_key'] = nil
default['chef_rails_backups']['aws_s3']['storage_class'] = nil
default['chef_rails_backups']['aws_s3']['region'] = nil
default['chef_rails_backups']['aws_s3']['bucket'] = nil
default['chef_rails_backups']['aws_s3']['path'] = nil
default['chef_rails_backups']['aws_s3']['keep'] = nil

default['chef_rails_backups']['aws_s3']['fog_options'] = nil

default['chef_rails_backups']['schedule']['enabled'] = false
default['chef_rails_backups']['schedule']['minute'] = nil
default['chef_rails_backups']['schedule']['hour'] = nil

default['chef_rails_backups']['schedule_database']['enabled'] = false
default['chef_rails_backups']['schedule_database']['minute'] = nil
default['chef_rails_backups']['schedule_database']['hour'] = nil

default['chef_rails_backups']['schedule_directories']['enabled'] = false
default['chef_rails_backups']['schedule_directories']['minute'] = nil
default['chef_rails_backups']['schedule_directories']['hour'] = nil

default['chef_rails_backups']['directories'] = []
