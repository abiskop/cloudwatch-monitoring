#
# Cookbook Name::       cloudwatch_monitoring
# Description::         Base configuration for cloudwatch_monitoring
# Recipe::              default
# Author::              Neill Turner
#
# Copyright 2013, Neill Turner
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe 'apt'
include_recipe 'zip'

apt_package "libwww-perl" do
  action :install
end

apt_package "libcrypt-ssleay-perl" do
  action :install
end

remote_file "#{node[:cw_mon][:home_dir]}/CloudWatchMonitoringScripts-v#{node[:cw_mon][:version]}.zip" do
  source "#{node[:cw_mon][:release_url]}"
  owner "#{node[:cw_mon][:user]}"
  group "#{node[:cw_mon][:group]}"
  mode 0755 
  not_if { ::File.exists?("#{node[:cw_mon][:home_dir]}/CloudWatchMonitoringScripts-v#{node[:cw_mon][:version]}.zip")}
end

execute "unzip cloud watch monitoring scripts" do
    command "unzip #{node[:cw_mon][:home_dir]}/CloudWatchMonitoringScripts-v#{node[:cw_mon][:version]}.zip"
    cwd "#{node[:cw_mon][:home_dir]}"
    user "#{node[:cw_mon][:user]}"
    group "#{node[:cw_mon][:group]}"
    not_if { ::File.exists?("#{node[:cw_mon][:home_dir]}/aws-scripts-mon")}
end

file "#{node[:cw_mon][:home_dir]}/CloudWatchMonitoringScripts-v#{node[:cw_mon][:version]}.zip" do
  action :delete    
  not_if { ::File.exists?("#{node[:cw_mon][:home_dir]}/CloudWatchMonitoringScripts-v#{node[:cw_mon][:version]}.zip")== false }
end

template "#{node[:cw_mon][:home_dir]}/aws-scripts-mon/awscreds.conf" do
  owner "#{node[:cw_mon][:user]}"
  group "#{node[:cw_mon][:group]}"
  mode 0644
  source "awscreds.conf.erb"
  variables     :cw_mon => node[:cw_mon]
end

access_mode_and_creds = ""
case node[:cw_mon][:aws_access_mode]
  when "iam-role"
    access_mode_and_creds = ""
    ### Currently, IAM role access control only works by relying on the IAM role attached to the instance.
    ### TODO: Add support for --aws-credential-file
    ###access_mode_and_creds = "--aws-iam-role=#{node[:cw_mon][:aws_iam_role]}"
  when "key"
    access_mode_and_creds = "--aws-credential-file #{node[:cw_mon][:home_dir]}/aws-scripts-mon/awscreds.conf"
end

verify_only = ""
if node[:cw_mon][:verify_only]
  verify_only = "--verify"
end

metrics_args = node[:cw_mon][:metrics].collect{ |metric| " --" + metric }.reduce(:+)

cron_command = "#{node[:cw_mon][:home_dir]}/aws-scripts-mon/mon-put-instance-data.pl #{access_mode_and_creds} #{verify_only} #{metrics_args} --disk-path=#{node[:cw_mon][:disk_path]} --from-cron"

if node[:cw_mon][:mock]
  cron_command = "echo \"" + cron_command + "\""
end

cron "cloudwatch_schedule_metrics" do
  action :create 
  minute node[:cw_mon][:cron_minutes]
  user "#{node[:cw_mon][:user]}"
  home "#{node[:cw_mon][:home_dir]}/aws-scripts-mon"
  command cron_command
end

