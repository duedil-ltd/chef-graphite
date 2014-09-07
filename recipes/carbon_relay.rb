#
# Cookbook Name:: graphite
# Recipe:: carbon_relay
#
# Copyright 2013, Onddo Labs, SL.
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

service_type = node['graphite']['carbon']['service_type']

case service_type
when 'runit'
  carbon_relay_service_resource = 'runit_service[carbon-relay]'
else
  carbon_relay_service_resource = 'service[carbon-relay]'
end

if node['graphite']['storage_schemas'].is_a?(Array) && node['graphite']['storage_schemas'].length > 0
  template "#{node['graphite']['base_dir']}/conf/storage-schemas.conf" do
    source 'storage.conf.erb'
    owner node['graphite']['user_account']
    group node['graphite']['group_account']
    variables(:storage_config => node['graphite']['storage_schemas'])
    only_if { node['graphite']['storage_schemas'].is_a?(Array) }
    notifies :restart, carbon_relay_service_resource
  end
else
  file "#{node['graphite']['base_dir']}/conf/storage-schemas.conf" do
    action :delete
    notifies :restart, carbon_relay_service_resource
  end
end

template "#{node['graphite']['base_dir']}/conf/relay-rules.conf" do
  owner node['graphite']['user_account']
  group node['graphite']['group_account']
  variables(:relay_rules => node['graphite']['relay_rules'])
  notifies :restart, carbon_relay_service_resource
end

include_recipe "#{cookbook_name}::#{recipe_name}_#{service_type}"
