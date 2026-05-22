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

# Build & install backup gem from git source into app user's rbenv.
# Needed because the 5.0.0.beta.3 release on rubygems predates Ruby 3.1+
# YAML safe_load behavior — its cycler.rb crashes on Psych::DisallowedClass
# (Backup::Package). The master branch contains the fix but no new release.
if node['chef_rails_backups']['gem']['from_git']
  src_dir = '/var/cache/backup-gem-src'

  directory src_dir do
    owner app.user
    group app.group
    mode '0755'
    recursive true
  end

  git src_dir do
    repository node['chef_rails_backups']['gem']['git_repo']
    revision node['chef_rails_backups']['gem']['git_branch']
    user app.user
    group app.group
    notifies :run, 'bash[install backup gem from git]', :immediately
  end

  bash 'install backup gem from git' do
    cwd src_dir
    user app.user
    group app.group
    environment(
      'HOME' => "/home/#{app.user}",
      'RBENV_ROOT' => "/home/#{app.user}/.rbenv",
      'RBENV_VERSION' => app.ruby_version,
      'PATH' => "/home/#{app.user}/.rbenv/shims:/home/#{app.user}/.rbenv/bin:/usr/bin:/bin"
    )
    code <<~SH
      set -e
      gem build backup.gemspec
      gem install --local --no-document backup-*.gem
      rm -f backup-*.gem
    SH
    action :nothing
  end
end

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
