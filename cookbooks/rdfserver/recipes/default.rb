if ['solo', 'app', 'app_master', 'util'].include?(node[:instance_role])
  node[:applications].each do |app_name, data|
    template "/data/#{app_name}/shared/config/rdfserver.yml" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      source "rdfserver.yml.erb"
    end
  end
end

