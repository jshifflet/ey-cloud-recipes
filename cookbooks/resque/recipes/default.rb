#
# Cookbook Name:: resque
# Recipe:: default
#
if ['solo', 'util'].include?(node[:instance_role]) && ['resque','utility'].include?(node[:name])

  execute "install resque gem" do
    command "gem install resque redis redis-namespace yajl-ruby -r"
    not_if { "gem list | grep resque" }
  end

  case node[:ec2][:instance_type]
    when 'm1.small'
      worker_count = 11
    when 'c1.medium'
      worker_count = 11
    when 'c1.xlarge'
      worker_count = 11
    else 
      worker_count = 4
    end

    node[:applications].each do |app, data|
      template "/etc/monit.d/resque_#{app}.monitrc" do 
      owner 'root' 
      group 'root' 
      mode 0644 
      source "monitrc.conf.erb" 
      variables({ 
      :num_workers => worker_count,
      :app_name => app, 
      :rails_env => node[:environment][:framework_env] 
      }) 
      end

      worker_count.times do |count|
        template "/data/#{app}/shared/config/resque_#{count}.conf" do
        owner node[:owner_name]
        group node[:owner_name]
        mode 0644
        source "resque_#{count}.conf.erb"
        end
      end
    
    template "/data/#{app}/shared/config/resque.yml" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      source "resque.yml.erb"
    end    

    execute "ensure-resque-is-setup-with-monit" do 
      command %Q{ 
      monit reload 
      } 
    end

    execute "restart-resque" do 
      command %Q{ 
        echo "sleep 20 && monit -g #{app}_resque restart all" | at now 
      }
    end
  end 
end

if ['solo', 'app', 'app_master'].include?(node[:instance_role])
  node[:applications].each do |app_name, data|
    template "/data/#{app_name}/shared/config/resque.yml" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      source "resque.yml.erb"
    end
  end
end
