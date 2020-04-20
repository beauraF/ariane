# frozen_string_literal: true

require 'byebug'

NODE_VERSION = %x{node --version}.delete('v').chomp
NODE_REQUIRED_VERSION = NODE_VERSION.gsub(/\.\d*.\d*$/, '.x')
YARN_VERSION =  %x{yarn --version}.chomp
YARN_REQUIRED_VERSION = YARN_VERSION.gsub(/\.\d*.\d*$/, '.x')

POSTGRESQL_VERSION = ask('PostgreSQL version:')
REDIS_VERSION = ask('Redis version:')
DEPENDABOT_DEFAULT_ASSIGNEE = ask('Dependabot default assignee:')

def source_paths
  [File.join(__dir__, 'sources')]
end

template '.editorconfig'
template '.eslintrc.yml'
template '.huskyrc.yml'
template '.lintstagedrc.yml'
template '.node-version'
template '.prettierignore'
template '.prettierrc.yml'
template '.rubocop.yml'
template 'Brewfile'
template 'docker-compose.yml'
template 'Gemfile', force: true
template 'package.json', force: true
template 'Procfile'
template 'README.md', force: true

directory '.dependabot'
directory '.github'
directory 'app', force: true
directory 'bin', force: true
directory 'config', force: true
directory 'test', force: true

run 'brew bundle install --no-lock'

after_bundle do
  template 'postcss.config.js', force: true
  gsub_file 'app/views/layouts/application.html.erb', 'stylesheet_link_tag', 'stylesheet_pack_tag'
  gsub_file 'config/webpacker.yml', 'resolved_paths: []', "resolved_paths: ['app/assets']"

  remove_file 'app/assets/stylesheets/application.css'
  remove_file 'app/controllers/concerns/.keep'
  remove_file 'app/javascript/controllers/hello_controller.js'
  remove_file 'test/controllers/.keep'

  run 'yarn upgrade'
end