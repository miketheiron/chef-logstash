# Encoding: utf-8
# Cookbook Name:: logstash
# Provider:: curator
# Author:: John E. Vincent
# License:: Apache 2.0
#
# Copyright 2014, John E. Vincent

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def load_current_resource
  @instance = new_resource.instance || 'default'
  @days_to_keep = new_resource.days_to_keep || Logstash.get_attribute_or_default(node, @instance, 'curator_days_to_keep')
  @minute = new_resource.minute || Logstash.get_attribute_or_default(node, @instance, 'curator_cron_minute')
  @hour = new_resource.hour || Logstash.get_attribute_or_default(node, @instance, 'curator_cron_hour')
  @log_file = new_resource.log_file || Logstash.get_attribute_or_default(node, @instance, 'curator_cron_log_file')
  @user = new_resource.user || Logstash.get_attribute_or_default(node, @instance, 'user')
  @bin_dir = new_resource.user || Logstash.get_attribute_or_default(node, @instance, 'curator_bin_dir')
  @version = new_resource.version || Logstash.get_attribute_or_default(node, @instance, 'curator_version')
  @delete_indices_regex = new_resource.delete_indices_regex || Logstash.get_attribute_or_default(node, @instance, 'curator_delete_indices_regex')
  @delete_indices_older_than = new_resource.delete_indices_older_than || Logstash.get_attribute_or_default(node, @instance, 'curator_delete_indices_older_than')
  @delete_indices_time_unit = new_resource.delete_indices_time_unit || Logstash.get_attribute_or_default(node, @instance, 'curator_delete_indices_time_unit')
  @delete_indices_timestring = new_resource.delete_indices_timestring || Logstash.get_attribute_or_default(node, @instance, 'curator_delete_indices_timestring')
end

action :create do
  cur_instance = @instance
  cur_days_to_keep = @days_to_keep
  cur_log_file = @log_file
  cur_hour = @hour
  cur_minute = @minute
  cur_user = @user
  cur_bin_dir = @bin_dir

  cur_version = @version
  cur_delete_indices_regex = @delete_indices_regex
  cur_delete_indices_older_than = @delete_indices_older_than
  cur_delete_indices_time_unit = @delete_indices_time_unit
  cur_delete_indices_timestring = @delete_indices_timestring

  @run_context.include_recipe 'python::pip'

  pi = python_pip 'elasticsearch-curator' do
    action :install
    version cur_version
  end
  new_resource.updated_by_last_action(pi.updated_by_last_action?)

  server_ip = ::Logstash.service_ip(node, cur_instance, 'elasticsearch')
  cr = cron "curator-#{cur_instance}" do
    command "#{cur_bin_dir}/curator --host #{server_ip} delete indices --regex '#{cur_delete_indices_regex}' --older-than #{cur_delete_indices_older_than} --time-unit #{cur_delete_indices_time_unit} --timestring '#{cur_delete_indices_timestring}' &> #{cur_log_file}"
    user    cur_user
    minute  cur_minute
    hour    cur_hour
    action  [:create]
  end
  new_resource.updated_by_last_action(cr.updated_by_last_action?)
end

action :delete do
  cur_instance = @instance
  cur_days_to_keep = @days_to_keep
  cur_log_file = @log_file
  cur_hour = @hour
  cur_minute = @minute
  cur_user = @user
  cur_bin_dir = @bin_dir

  cur_version = @version
  cur_delete_indices_regex = @delete_indices_regex
  cur_delete_indices_older_than = @delete_indices_older_than
  cur_delete_indices_time_unit = @delete_indices_time_unit
  cur_delete_indices_timestring = @delete_indices_timestring

  @run_context.include_recipe 'python::pip'

  pi = python_pip 'elasticsearch-curator' do
    action :uninstall
  end
  new_resource.updated_by_last_action(pi.updated_by_last_action?)

  cr = cron "curator-#{cur_instance}" do
    command "#{cur_bin_dir}/curator --host #{server_ip} delete indices --regex '#{cur_delete_indices_regex}' --older-than #{cur_delete_indices_older_than} --time-unit #{cur_delete_indices_time_unit} --timestring '#{cur_delete_indices_timestring}' &> #{cur_log_file}"
    user    cur_user
    minute  cur_minute
    hour    cur_hour
    action  [:delete]
  end
  new_resource.updated_by_last_action(cr.updated_by_last_action?)
end
