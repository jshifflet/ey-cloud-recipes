app_name = 'rails_3_production'

if ['solo', 'app', 'app_master'].include?(node[:instance_role])
  template "/etc/init.d/result_server" do
    source "result_server_bin.erb"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0700
    variables({
      :app_name => app_name,
      :user => node[:owner_name],
    })
  end
  
  template "/etc/monit.d/result_server.monitrc" do
    source "result_server.monitrc.erb"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0644
    variables({
      :app_name => app_name,
      :user => node[:owner_name],
    })
  end
end

