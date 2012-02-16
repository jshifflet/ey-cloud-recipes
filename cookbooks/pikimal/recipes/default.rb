#
# Cookbook Name:: pikimal
# Recipe:: default
#

app_name = 'rails3_staging'
env = node[:environment][:framework_env]
  
# Adds the cronjob that warms the semantic template cache and runs maps.

if (['solo'].include?(node[:instance_role])) ||
    (node[:instance_role] == 'util' && ['utility','resque'].include?(node[:name]))
  warm_semantic_template_cache_cmd = "cd /data/#{app_name}/current && " + 
    "RAILS_ENV=#{env} " + 
    "bundle exec " + 
    "rake environment pikimal:warm_semantic_template_cache"

  cron "pikimal:warm_semantic_template_cache" do
    user node[:owner_name]
    hour "3"
    minute "0"
    command warm_semantic_template_cache_cmd
    action :create
  end

  run_maps_cmd = "cd /data/#{app_name}/current && " + 
    "RAILS_ENV=#{env} " + 
    "bundle exec " + 
    "rake environment pikimal:run_maps"
  
  cron "pikimal:run_maps" do
    user node[:owner_name]
    hour "4"
    minute "0"
    command run_maps_cmd
    action :create
  end
  
end

if ['solo', 'app_master', 'app'].include?(node[:instance_role])
  link "/data/#{app_name}/current/public/robots.txt" do
    action :delete
  end

  template "/data/#{app_name}/shared/public/robots.txt" do
    action :delete
  end
end
