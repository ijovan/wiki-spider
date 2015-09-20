Given(/^that I'm on the home page$/) do
  visit("/")
end

Given(/^that I've set two correct links$/) do
  fill_in "start_node", :with => "https://en.wikipedia.org/wiki/Novi_Sad"
  fill_in "end_node", :with => "https://en.wikipedia.org/wiki/Ljubljana"
end

When(/^I run search$/) do
  click_button("Search!")
end

Then(/^I should get a response confirming the start of search$/) do
  page.should have_content("Search running...")
end
