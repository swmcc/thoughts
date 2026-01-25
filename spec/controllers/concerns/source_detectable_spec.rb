require "rails_helper"
require "ostruct"

RSpec.describe SourceDetectable do
  let(:test_class) do
    Class.new do
      include SourceDetectable

      attr_accessor :request

      def initialize(user_agent)
        @request = OpenStruct.new(user_agent: user_agent)
      end

      def detect
        detect_source
      end
    end
  end

  describe "#detect_source" do
    context "with iPhone Safari user agent" do
      let(:user_agent) { "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1" }

      it "returns iphone" do
        expect(test_class.new(user_agent).detect).to eq("iphone")
      end
    end

    context "with iPad Safari user agent" do
      let(:user_agent) { "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1" }

      it "returns iphone" do
        expect(test_class.new(user_agent).detect).to eq("iphone")
      end
    end

    context "with curl user agent" do
      let(:user_agent) { "curl/8.1.2" }

      it "returns cli" do
        expect(test_class.new(user_agent).detect).to eq("cli")
      end
    end

    context "with httpie user agent" do
      let(:user_agent) { "HTTPie/3.2.1" }

      it "returns cli" do
        expect(test_class.new(user_agent).detect).to eq("cli")
      end
    end

    context "with wget user agent" do
      let(:user_agent) { "Wget/1.21" }

      it "returns cli" do
        expect(test_class.new(user_agent).detect).to eq("cli")
      end
    end

    context "with python-requests user agent" do
      let(:user_agent) { "python-requests/2.28.0" }

      it "returns cli" do
        expect(test_class.new(user_agent).detect).to eq("cli")
      end
    end

    context "with empty user agent" do
      let(:user_agent) { "" }

      it "returns cli" do
        expect(test_class.new(user_agent).detect).to eq("cli")
      end
    end

    context "with nil user agent" do
      let(:user_agent) { nil }

      it "returns cli" do
        expect(test_class.new(user_agent).detect).to eq("cli")
      end
    end

    context "with Chrome desktop user agent" do
      let(:user_agent) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }

      it "returns web" do
        expect(test_class.new(user_agent).detect).to eq("web")
      end
    end

    context "with Firefox desktop user agent" do
      let(:user_agent) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0" }

      it "returns web" do
        expect(test_class.new(user_agent).detect).to eq("web")
      end
    end

    context "with Safari desktop user agent" do
      let(:user_agent) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15" }

      it "returns web" do
        expect(test_class.new(user_agent).detect).to eq("web")
      end
    end
  end
end
