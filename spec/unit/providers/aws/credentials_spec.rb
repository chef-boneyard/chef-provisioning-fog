require 'chef/provisioning/fog_driver/providers/aws/credentials'

describe Chef::Provisioning::FogDriver::Providers::AWS::Credentials do
  let(:credentials) { Chef::Provisioning::FogDriver::Providers::AWS::Credentials.new }

  describe "#load_inis" do
    let(:aws_credentials_ini_file) { File.join(File.expand_path('../../../../support', __FILE__), 'aws/ini-file.ini') }

    before do
      credentials.load_inis(aws_credentials_ini_file)
    end

    it "should load a default profile" do
      expect(credentials['default']).to include(:aws_access_key_id)
    end

    it "should load the correct values" do
      expect(credentials['default'][:aws_access_key_id]).to eq 12345
      expect(credentials['default'][:aws_secret_access_key]).to eq "abcde"
      expect(credentials['default'][:region]).to eq "us-east-1"
      expect(credentials['default'][:aws_session_token]).to eq "mysecret"
    end

    it "should load several profiles" do
      expect(credentials.keys.length).to eq 2
    end
  end

  describe "#load_csv" do
    let(:aws_credentials_csv_file) { File.join(File.expand_path('../../../../support', __FILE__), 'aws/config-file.csv') }
    before do
      credentials.load_csv(aws_credentials_csv_file)
    end

    it "should load a single profile" do
      expect(credentials['test']).to include(:aws_access_key_id)
    end

    it "should load the correct values" do
      expect(credentials['test'][:aws_access_key_id]).to eq "67890"
    end

    it "should load several profiles" do
      expect(credentials.keys.length).to eq 1
    end
  end
end
