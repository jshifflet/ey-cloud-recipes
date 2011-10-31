require 'pp'
#
# Cookbook Name:: memcached
# Recipe:: default
#

appname = 'rails3_staging'

# If the server is a memcached box.
if node[:name] == 'memcached'
  package "memcached" do
    action :install
  end

  max_connections = 1024

  # Just for sanity's sake we'll use 90% of the server's total RAM. If we 
  # decide that additional 10% is worth it then we can change the config.
  # I just wanted to sane default to get going.
  size = `curl -s http://instance-data.ec2.internal/latest/meta-data/instance-type`
  case size
  when /m1.small/ # 1.7G RAM, 1 ECU, 32-bit, 1 core
    memusage = 1530
  when /m1.large/ # 7.5G RAM, 4 ECU, 64-bit, 2 cores
    memusage = 6750
  when /m1.xlarge/ # 15G RAM, 8 ECU, 64-bit, 4 cores
    memusage = 13500
  when /c1.medium/ # 1.7G RAM, 5 ECU, 32-bit, 2 cores
    memusage = 1530
  when /c1.xlarge/ # 7G RAM, 20 ECU, 64-bit, 8 cores
    memusage = 6300
  when /m2.xlarge/ # 17.1G RAM, 6.5 ECU, 64-bit, 2 cores
    memusage = 15390
    max_connections = 2048
  when /m2.2xlarge/ # 34.2G RAM, 13 ECU, 64-bit, 4 cores
    memusage = 30780
    max_connections = 2048
  when /m2.4xlarge/ # 68.4G RAM, 26 ECU, 64-bit, 8 cores
    memusage = 61560
    max_connections = 2048
  else # This shouldn't happen, but do something rational if it does.
    memusage = 64
  end

  template "/etc/monit.d/memcached.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "memcached.monitrc.erb"
    variables :port => 11211
  end

  template "/etc/conf.d/memcached" do
    owner 'root'
    group 'root'
    mode 0644
    source "memcached.erb"
    variables :memusage        => memusage,
              :listenon        => node[:hostname],
              :max_connections => max_connections,
              :port            => 11211
  end
  
# if it's any other kind of utility server...
elsif node[:instance_role].include?('util')
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
else
  
  servers = []
  node[:utility_instances].each do |node|
    if node[:name]== 'memcached'
      servers << node[:hostname]
    end
  end
  
  memory = 61560
  
  case node[:instance_role]
  when "solo", "app", "app_master"
    user = node[:users].first
    ttl = 604800

    run_for_app(appname) do |app_name, data|
      template "/data/#{app_name}/shared/config/memcached_custom.yml" do
        source "memcached.yml.erb"
        owner user[:username]
        group user[:username]
        mode 0744
        variables({
          :ttl => ttl,
          :memory => memory,
          :app_name => app_name,
          :server_names => servers
        })
      end
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
