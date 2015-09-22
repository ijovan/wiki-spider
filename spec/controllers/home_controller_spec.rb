require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    it "returns http ok" do
      get "index"

      assert_response 200
    end
  end

  describe "POST 'create'" do
    context "correct input" do
      before do
        @start_node = "https://en.wikipedia.org/wiki/Novi_Sad"
        @end_node = "https://en.wikipedia.org/wiki/Ljubljana"
        @channel = "123"

        @params = {
          "startNode" => @start_node,
          "endNode" => @end_node,
          "channel" => @channel
        }.to_json

        allow(Process).to receive(:fork)
        allow(Reader).to receive(:find_by_url)
      end

      it "returns http ok" do
        #expect(Reader).to receive(:find_by_url).with(@start_node, @end_node, @channel)

        post("create", @params)

        assert_response 200
      end
    end
  end

end
