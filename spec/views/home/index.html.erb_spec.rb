require 'spec_helper'

describe "home/index.html.erb" do
  it "contains node fields" do
    render

    rendered.should have_selector("[name=start_node][type=text]")
    rendered.should have_selector("[name=end_node][type=text]")

    rendered.should have_selector("[name=search][type=submit]")
  end
end
