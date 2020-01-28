#
# Cookbook:: ELK_cookbook
# Spec:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'ELK_cookbook::default' do
  context 'When all attributes are default, on Ubuntu 18.04' do
    # for a complete list of available platforms and versions see:
    # https://github.com/chefspec/fauxhai/blob/master/PLATFORMS.md
    platform 'ubuntu', '18.04'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
    it 'updates ubuntu' do
      expect(chef_run).to update_apt_update('update ubuntu')
    end
    it 'openjdk-8-jdk' do
      expect(chef_run).to install_apt_package('openjdk-8-jdk')
    end
    it 'elasticsearch' do
      expect(chef_run).to install_elasticsearch_install('elasticsearch')
    end
    it 'logstash install' do
      expect(chef_run).to run_script('logstash install')
    end
    it 'load filebeat index to elasticsearch' do
      expect(chef_run).to run_script('load filebeat index to elasticsearch')
    end
  end

end
