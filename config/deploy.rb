# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'capistrano-demo'
set :repo_url, 'git@github.com:AtulKsol/capistrano-demo.git'

set :stages, ["staging", "production"]
set :default_stage, "production"

set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }

# deploy_via command makes Capistrano do a single clone/checkout of your repository on your server the first time, then do an svn up or git pull on every deploy instead of doing an entire clone/export.
set :deploy_via, :remote_cache
set :bundle_flags, '--quiet' # '--deployment --quiet' is the default

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
# set :linked_files, fetch(:linked_files, []).push('Gemfile.lock')

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

  desc 'Precompiling Assets for Production Environment. Assets can also be precompile in Capistrano 3,
        by adding/uncommenting `require capistrano/rails/assets` in Capfile and adding capistrano-rails gem in Gemfile'
  task :precompile_assets do
    on roles(:web) do
      within release_path do
        puts "Precompiling Assets..."
        execute :rake, "assets:precompile RAILS_ENV=production"
      end
    end
  end


  desc "Rollback to specific release version. Run this task manually by cap production `deploy:rollback_to_version`"
  task :rollback_to_version do
    on roles :app do
      ask(:version, "")
      if fetch(:version).present?
        puts "Rolling back to Version #{fetch(:version)}"

        # Check if directry exists, if exists then create the symlink to specified release version
        execute "if test -d #{releases_path.join(fetch(:version))}
                  then rm -f #{current_path} && ln -s #{releases_path.join(fetch(:version))} #{current_path}
                else echo 'Directory not found'
                fi;"
      else
        puts "Incorrect Release Version"
      end
    end
  end

  desc "Check Server Config"
  task :check_server_config do
    puts "SERVER_IP ==> #{ENV["SERVER_IP"]}"
    puts "SERVER_USER ==> #{ENV["SERVER_USER"]}"
    puts "PEM_FILE_LOC ==> #{ENV["PEM_FILE_LOC"]}"
  end

  # after :publishing, 'precompile_assets'
  before :check, 'check_server_config'
end

desc "Test Task description"
task :hello do
	ask(:breakfast, "cakes")
  puts "release_path => #{release_path}"
  puts "current_path => #{current_path}"
  puts "deploy_path => #{deploy_path}"
	puts "Hello World"
	puts "Breakfast: #{fetch(:breakfast)}"
  puts "#{release_path.parent}"
  puts "#{releases_path.basename}"
  puts "#{release_path.parent.join(current_path.basename)}"
end