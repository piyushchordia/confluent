require 'spec_helper'

describe 'confluent::default' do

  before do
    Fauxhai.mock(platform:'centos', version:'6.5')
  end

  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set["confluent"]["version"] = "1.2.1"
      node.set["confluent"]["scala_version"] = "2.11.1"
      node.set["confluent"]["install_dir"] = "/opt/confluent_other"
      node.set["confluent"]["kafka"]["server.properties"]["key"] = "value1"
      node.set["confluent"]["kafka"]["log4j.properties"]["key"] = "log1"
      node.set["confluent"]["kafka-rest"]["kafka-rest.properties"]["key"] = "value2"
      node.set["confluent"]["kafka-rest"]["log4j.properties"]["key"] = "log2"
      node.set["confluent"]["schema-registry"]["schema-registry.properties"]["key"] = "value3"
      node.set["confluent"]["schema-registry"]["log4j.properties"]["key"] = "log3"
      node.set['confluent']['kafka']['server.properties']['broker.id'] = 1
      node.set['confluent']['kafka']['zookeepers'] = 'testhost.chefspec'
    end
  end

  it 'should install confluent' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_directory('/opt/confluent_other')
    expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/confluent-1.2.1-2.11.1.zip").with(source: 'http://packages.confluent.io/archive/1.2.1/confluent-1.2.1-2.11.1.zip')
    expect(chef_run).to run_execute("unzip -q #{Chef::Config[:file_cache_path]}/confluent-1.2.1-2.11.1.zip -d /opt/confluent_other")
  end

  it 'should configure kafka' do
    chef_run.converge(described_recipe)
    expect(chef_run).to render_file('/etc/kafka/server.properties').with_content('key=value1')
    expect(chef_run).to render_file('/etc/kafka/log4j.properties').with_content('key=log1')
  end

  it 'should configure kafka-rest' do
    chef_run.converge(described_recipe)
    expect(chef_run).to render_file('/etc/kafka-rest/kafka-rest.properties').with_content('key=value2')
    expect(chef_run).to render_file('/etc/kafka-rest/log4j.properties').with_content('key=log2')
  end

  it 'should configure schema-registry' do
    chef_run.converge(described_recipe)
    expect(chef_run).to render_file('/etc/schema-registry/schema-registry.properties').with_content('key=value3')
    expect(chef_run).to render_file('/etc/schema-registry/log4j.properties').with_content('key=log3')
  end

end
