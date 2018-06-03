resource_name :rails_backup

property :backup_name, name_property: true
property :app
property :schedule_minute
property :schedule_hour
property :aws_s3
property :postgresql
property :backup_database
property :backup_directories

action :create do
  config = <<-CONFIG
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

  if backup_database
    config += <<-CONFIG

      database PostgreSQL do |db|
        db.name               = "#{app.name}_#{app.env}"
        db.username           = "#{postgresql['username']}"
        db.password           = "#{postgresql['password']}"
        db.host               = "#{postgresql['host']}"
        db.port               = 5432
        db.additional_options = ["-xc", "-E=utf8"]
        # db.only_tables        = []
        # db.skip_tables        = []
      end
    CONFIG
  end

  if backup_directories && backup_directories.any?
    directories = backup_directories.map do |v|
      "          directory.add \"#{app.dir :root}/#{v}\""
    end.join("\n")

    config += <<-CONFIG

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
          # directory.exclude '**/*~'
          # directory.exclude /\/tmp$/
        end
      end
    CONFIG
  end

  backup_model backup_name do
    description "Back up #{backup_name}"
    definition config
    schedule(
      minute: schedule_minute,
      hour: schedule_hour
    )
    cron_options(
      command: <<~COMMAND.tr("\n", ' ')
        /bin/bash -il -c \"
        RBENV_ROOT=/home/#{app.user}/.rbenv
        RBENV_VERSION=#{app.ruby_version}
        /home/#{app.user}/.rbenv/bin/rbenv exec
        backup perform --trigger #{backup_name} --root-path /opt/backup/ > /dev/null
        \"
      COMMAND
    )
  end
end
