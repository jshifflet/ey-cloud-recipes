#
# Cookbook Name:: pikimal
# Recipe:: default
#

app_name = 'rails_3_production'
env = node[:environment][:framework_env]
  
# Adds the cronjob that warms the semantic template cache.
#
# App_master really isn't the best place for this, but EngineYard seems to
# think so. I really don't want to fight with EngineYard so I'll just do it 
# their stupid way.
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
  template "/data/#{app_name}/shared/public/robots.txt" do
    mode 0640
    source "robots.txt.#{app_name}.erb"
  end
end
