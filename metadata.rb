# frozen_string_literal: true

name             'chef_rails_backups'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures chef_rails_backups'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

depends 'backup'
depends 'git'
depends 'cron'
