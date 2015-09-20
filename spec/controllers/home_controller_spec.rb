require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    it "returns http ok" do
      get 'index'
      assert_response 200
    end
  end

  describe "POST 'create'" do
    context "correct input" do
      before do
        @start_node = "https://en.wikipedia.org/wiki/Novi_Sad"
        @end_node = "https://en.wikipedia.org/wiki/Ljubljana"
      end

      it "returns http ok" do
        post 'create'
        assert_response 200
      end
    end
  end

end
