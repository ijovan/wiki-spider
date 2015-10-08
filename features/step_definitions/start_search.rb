Given(/^that I'm on the home page$/) do
  visit("/")
end

Given(/^that I've set two correct links$/) do
  fill_in "start_node", :with => "https://en.wikipedia.org/wiki/Novi_Sad"
  fill_in "end_node", :with => "https://en.wikipedia.org/wiki/Ljubljana"
end

When(/^I run search$/) do
  click_button("Go!")
  sleep(8)
end

Then(/^I should start seeing results$/) do
  page.should have_content("Connecting Novi_Sad and Ljubljana")
end
