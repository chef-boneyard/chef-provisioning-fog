require 'chef/provisioning/fog_driver/providers/aws/credentials'

describe Chef::Provisioning::FogDriver::Providers::AWS::Credentials do
  subject { Chef::Provisioning::FogDriver::Providers::AWS::Credentials.new }
  
  describe "#load_inis" do
    let(:aws_credentials_ini_file) { File.join(File.expand_path('../../../../support', __FILE__), 'aws/ini-file.ini') }

    before do
      subject.load_inis(aws_credentials_ini_file)
    end

    it "should load a default profile" do
      expect(subject['default']).to include(:aws_access_key_id)
    end

    it "should load the correct values" do
      expect(subject['default'][:aws_access_key_id]).to eq "12345"
      expect(subject['default'][:aws_secret_access_key]).to eq "abcde"
      expect(subject['default'][:region]).to eq "us-east-1"
      expect(subject['default'][:aws_session_token]).to eq "mysecret"
    end

    it "should load several profiles" do
      expect(subject.keys.length).to eq 2
    end
  end

  describe "#load_csv" do
    let(:aws_credentials_csv_file) { File.join(File.expand_path('../../../../support', __FILE__), 'aws/config-file.csv') }
    before do
      subject.load_csv(aws_credentials_csv_file)
    end

    it "should load a single profile" do
      expect(subject['test']).to include(:aws_access_key_id)
    end

    it "should load the correct values" do
      expect(subject['test'][:aws_access_key_id]).to eq "67890"
    end

    it "should load several profiles" do
      expect(subject.keys.length).to eq 1
    end
  end
end
