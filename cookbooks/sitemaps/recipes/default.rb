if ['solo', 'app', 'app_master'].include?(node[:instance_role])
  cron "sitemaps_generator" do
    weekday  '5'
    user    node[:owner_name]
    command "cd /data/rails_3_production/current && RAILS_ENV=production bundle exec rake environment pikimal:generate_piki_sitemaps"
  end
end
