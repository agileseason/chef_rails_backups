# frozen_string_literal: true

name             'chef_rails_backups'
maintainer       'Andrey Sidorov'
maintainer_email 'takandar@gmail.com'
license          'MIT'
description      'Installs/Configures chef_rails_backups'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'

depends 'backup'
depends 'git'
depends 'cron'
