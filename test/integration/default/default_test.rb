# InSpec test for recipe ELK_cookbook::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

# This is an example test, replace it with your own test.
describe port(80), :skip do
  it { should_not be_listening }
end

describe service('elasticsearch') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe service('logstash') do
  it { should be_installed }
  it { should be_running }
end

describe service('kibana') do
  it { should be_installed }
  it { should be_running }
end

describe service('nginx') do
  it { should be_installed }
  it { should be_running }
end
