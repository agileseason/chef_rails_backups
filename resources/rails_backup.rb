resource_name :rails_backup
provides :rails_backup

property :backup_name, name_property: true
property :app
property :schedule_minute
property :schedule_hour
property :aws_s3
property :fog_options
property :postgresql
property :backup_database
property :backup_directories

action :create do
  if new_resource.aws_s3['storage_class']
    s3_storage_class = <<-CONFIG
      s3.storage_class     = "#{new_resource.aws_s3['storage_class']}"
    CONFIG
  end
  if new_resource.aws_s3['region']
    s3_region = <<-CONFIG
      s3.region            = "#{new_resource.aws_s3['region']}"
    CONFIG
  end
  if new_resource.aws_s3['fog_options']['endpoint']
    s3_fog_options = <<-CONFIG
      s3.fog_options       = {
        endpoint: "#{new_resource.aws_s3['fog_options']['endpoint']}"
      }
    CONFIG
  end

  config = <<-CONFIG
    compress_with Gzip

    store_with S3 do |s3|
      # AWS Credentials
      s3.access_key_id     = "#{new_resource.aws_s3['access_key_id']}"
      s3.secret_access_key = "#{new_resource.aws_s3['secret_access_key']}"
#{s3_storage_class}
#{s3_fog_options}

#{s3_region}
      s3.bucket            = "#{new_resource.aws_s3['bucket']}"
      s3.path              = "#{new_resource.aws_s3['path']}"
      s3.keep              = "#{new_resource.aws_s3['keep']}"
    end
  CONFIG

  if new_resource.backup_database
    config += <<-CONFIG

      database PostgreSQL do |db|
        db.name               = "#{new_resource.postgresql['database'] || "#{new_resource.app.name}_#{new_resource.app.env}"}"
        db.username           = "#{new_resource.postgresql['username']}"
        db.password           = "#{new_resource.postgresql['password']}"
        db.host               = "#{new_resource.postgresql['host']}"
        db.port               = 5432
        db.additional_options = ["-xc", "-E=utf8"]
        # db.only_tables        = []
        # db.skip_tables        = []
      end
    CONFIG
  end

  if new_resource.backup_directories && new_resource.backup_directories.any?
    directories = new_resource.backup_directories.map do |v|
      "          directory.add \"#{new_resource.app.dir :root}/#{v}\""
    end.join("\n")

    config += <<-CONFIG

      sync_with Cloud::S3 do |s3|
        s3.access_key_id     = "#{new_resource.aws_s3['access_key_id']}"
        s3.secret_access_key = "#{new_resource.aws_s3['secret_access_key']}"
        s3.storage_class     = "#{new_resource.aws_s3['storage_class']}"

        s3.region            = "#{new_resource.aws_s3['region']}"
        s3.bucket            = "#{new_resource.aws_s3['bucket']}"
        s3.path              = "#{new_resource.aws_s3['path']}"

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

  backup_model new_resource.backup_name do
    description "Back up #{new_resource.backup_name}"
    definition config
    schedule(
      minute: new_resource.schedule_minute,
      hour: new_resource.schedule_hour
    )
    cron_options(
      command: <<~COMMAND.tr("\n", ' ')
        /bin/bash -il -c \"
        rm -rf /opt/backup/.data &&
        rm -rf /opt/backup/.tmp &&
        RBENV_ROOT=/home/#{new_resource.app.user}/.rbenv
        RBENV_VERSION=#{new_resource.app.ruby_version}
        /home/#{new_resource.app.user}/.rbenv/bin/rbenv exec
        backup perform --trigger #{new_resource.backup_name} --root-path /opt/backup/ > /dev/null
        \"
      COMMAND
    )
  end
end
