app_name = 'rails3_staging'

if ['solo', 'app', 'app_master'].include?(node[:instance_role])
  
  execute 'stop results server' do
    command %Q{
      cd /data/#{app_name}/current && nohup rake environment pikimal:stop_result_server &
    }
  end

  execute 'start results server' do
    command %Q{
      cd /data/#{app_name}/current && nohup rake environment pikimal:start_result_server &

    }
  end  

end

