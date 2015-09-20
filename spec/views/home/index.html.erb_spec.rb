require 'spec_helper'

describe "home/index.html.erb" do
  it "contains node fields" do
    render

    rendered.should have_selector("#start_node[type=text]")
    rendered.should have_selector("#end_node[type=text]")

    rendered.should have_selector("#search[type=button]")
  end
end
