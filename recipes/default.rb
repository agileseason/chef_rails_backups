#
# Cookbook Name:: chef_rails_backups
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

app = AppHelpers.new node['app']

node.override['backup']['user'] = app.user
node.override['backup']['group'] = app.group
include_recipe 'backup'

aws_s3 = node['chef_rails_backups']['aws_s3']
postgresql = node['chef_rails_backups']['postgresql']
schedule = node['chef_rails_backups']['schedule']

directories = node['chef_rails_backups']['directories'].map do |dir_name|
  "directory.add \"#{app.dir :root}/#{dir_name}\""
end.join("\n")

backup_model app.name do
  description "Back up #{app.name} database"

  definition <<-CONFIG
  sync_with Cloud::S3 do |s3|
    s3.access_key_id     = "#{aws_s3['access_key_id']}"
    s3.secret_access_key = "#{aws_s3['secret_access_key']}"
    s3.storage_class     = "#{aws_s3['storage_class']}"

    s3.region            = "#{aws_s3['region']}"
    s3.bucket            = "#{aws_s3['bucket']}"
    s3.path              = "#{aws_s3['path']}"

    s3.mirror            = true
    s3.thread_count      = 10

    s3.directories do |directory|
      #{directories}

      # Exclude files/folders.
      # The pattern may be a shell glob pattern (see `File.fnmatch`) or a Regexp.
      # All patterns will be applied when traversing each added directory.
      # directory.exclude '**/*~'
      # directory.exclude /\/tmp$/
    end
  end

  database PostgreSQL do |db|
    db.name               = "#{app.name}_#{app.env}"
    db.username           = "#{postgresql['username']}"
    db.password           = "#{postgresql['password']}"
    db.host               = "localhost"
    db.port               = 5432
    db.additional_options = ["-xc", "-E=utf8"]
    # db.socket            = "/tmp/pg.sock"
    # db.only_tables        = []
    # db.skip_tables        = []
  end

  compress_with Gzip

  store_with S3 do |s3|
    # AWS Credentials
    s3.access_key_id     = "#{aws_s3['access_key_id']}"
    s3.secret_access_key = "#{aws_s3['secret_access_key']}"
    s3.storage_class     = "#{aws_s3['storage_class']}"

    s3.region            = "#{aws_s3['region']}"
    s3.bucket            = "#{aws_s3['bucket']}"
    s3.path              = "#{aws_s3['path']}"
    s3.keep              = "#{aws_s3['keep']}"
  end
CONFIG

  schedule(
    minute: schedule['minute'],
    hour: schedule['hour']
  )

  cron_options(
    command: <<~COMMAND.tr("\n", ' ')
      /bin/bash -il -c \"
      RBENV_ROOT=/home/#{app.user}/.rbenv
      RBENV_VERSION=#{app.ruby_version}
      /home/#{app.user}/.rbenv/bin/rbenv exec
      backup perform --trigger #{app.name} --root-path /opt/backup/ > /dev/null
      \"
    COMMAND
  )
end
