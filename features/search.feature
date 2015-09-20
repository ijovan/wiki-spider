Feature: Search
  In order to find a link
  As a user
  I want to input links
  And run the search
  And watch the results

  Background:
    Given that I'm on the home page

  @javascript
  Scenario: Start search
    Given that I've set two correct links
    When I run search
    Then I should get a response confirming the start of search
