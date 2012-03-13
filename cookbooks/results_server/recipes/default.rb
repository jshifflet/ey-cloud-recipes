if false #['solo', 'app', 'app_master'].include?(node[:instance_role])  && File.exists?("/data/#{app_name}/current")
  node[:applications].each do |app_name, data|
    template "/etc/init.d/result_server.#{app_name}" do
      source "result_server_bin.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0700
      variables({
        :app_name => app_name,
        :user => node[:owner_name],
      })
    end
    
    template "/etc/monit.d/result_server.#{app_name}.monitrc" do
      source "result_server.monitrc.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      variables({
        :app_name => app_name,
        :user => node[:owner_name],
      })
    end
    
    execute "ensure-result-server-is-running" do
      user node[:owner_name]
      command "/etc/init.d/result_server.#{app_name} restart"
    end
    
    execute "ensure-result-server-is-setup-with-monit" do 
      command "monit reload"
    end

    execute "restart-result-server" do 
      command "echo \"sleep 20 && monit -g result_server_#{app_name} restart all\" | at now"
    end  
  end
end
