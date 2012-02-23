if ['solo', 'app', 'app_master'].include?(node[:instance_role])
  enable_package "www-servers/nginx" do
    version "1.0.10"
  end

  package "www-servers/nginx" do
    version "1.0.10"
    action :install
  end

  node[:applications].each do |app_name, data|
    template "/etc/nginx/servers/#{app_name}.rewrites" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      source "rewrites.conf.erb" 
    end
  end

  service "nginx" do
    supports :status => true, :stop => true, :restart => true, :staus => true
    action :restart
  end
end
