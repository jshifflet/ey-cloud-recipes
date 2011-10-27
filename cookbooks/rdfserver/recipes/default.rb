appname = 'rails_3_production'

if ['solo', 'app', 'app_master'].include?(node[:instance_role])
  run_for_app(appname) do |app_name, data|
    template "/data/#{app_name}/shared/config/rdfserver.yml" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      source "rdfserver.yml.erb"
    end
  end
end

