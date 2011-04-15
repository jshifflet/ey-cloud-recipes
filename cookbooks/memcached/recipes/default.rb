require 'pp'
#
# Cookbook Name:: memcached
# Recipe:: default
#
appname = 'rails3_staging'

node[:members].each do |app_name,data|
  user = node[:users].first

case node[:instance_role]
 when "solo", "app", "app_master"
 run_for_app(appname) do |app_name, data|
   template "/data/#{app_name}/shared/config/memcached_custom.yml" do
     source "memcached.yml.erb"
     owner user[:username]
     group user[:username]
     mode 0744
     variables({
         :app_name => app_name,
         :server_names => node[:members]
     })
   end

   template "/etc/conf.d/memcached" do
     owner 'root'
     group 'root'
     mode 0644
     source "memcached.erb"
     variables :memusage => 64,
               :port     => 11211
   end
 end
 end
end

if node[:instance_role].include?('util')

  user = node[:users].first

  run_for_app(appname) do |app_name, data|
   template "/data/#{app_name}/shared/config/memcached_custom.yml" do
     source "memcached.yml.erb"
     owner user[:username]
     group user[:username]
     mode 0744
     variables({
         :app_name => app_name,
         :server_names => node[:members]
     })
   end
  end
end
