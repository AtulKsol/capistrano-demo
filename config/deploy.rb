# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'capistrano-demo'
set :repo_url, 'git@github.com:AtulKsol/capistrano-demo.git'

set :stages, ["staging", "production"]
set :default_stage, "production"

set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }

# deploy_via command makes Capistrano do a single clone/checkout of your repository on your server the first time, then do an svn up or git pull on every deploy instead of doing an entire clone/export.
set :deploy_via, :remote_cache

# set :bundle_gemfile, -> { release_path.join('Gemfile') }
# set :bundle_dir, -> { shared_path.join('bundle') }

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  desc 'Precompiling Assets fr Production Environment'
  task :precompile_assets do
    on roles(:web) do
      within release_path do
        puts "Precompiling Assets..."
        execute :rake, "assets:precompile RAILS_ENV=production"
      end
    end
  end

  desc "puts Check Server Config"
  task :check_server_config do
    puts "SERVER_IP ==> #{ENV["SERVER_IP"]}"
    puts "SERVER_USER ==> #{ENV["SERVER_USER"]}"
    puts "PEM_FILE_LOC ==> #{ENV["PEM_FILE_LOC"]}"
  end

  after :publishing, 'precompile_assets'
  before :check, 'check_server_config'
end

desc "Test Task description"
task :hello do
	ask(:breakfast, "pancakes")
	puts "Hello World"
	puts "breakfast: #{fetch(:breakfast)}"
end
