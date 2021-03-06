Feature: Testing RAILS_INTRO homework
  In order to check that the supplied homework can be graded by AutoGrader
  As a AutoGrader maintainer
  I would like these homeworks to be automatically tested on submit


  Background: The homework is in place
    Given I have the public skeleton "saasbook/rails-intro" in "."
    And it is on the "master" branch
    And I have the reference application in "rails-intro"
    And I have the homework in "."


  Scenario Outline: Runs on HEROKU SOLUTION
    When I run AutoGrader with "Heroku grader" strategy for <test_subject> and <spec>
    Then I should see that the results are <expected_result>
    And I should see the execution results with <test_title>
  Examples:
    | test_title                      | test_subject                | spec                                       | expected_result       |
    | Part1: specs vs remote solution | solutions/lib/hw2_uri       | autograder/combined_rails_intro_spec.rb    | Score out of 100: 100 |


  Scenario Outline: Runs LOCAL SKELETON
    Given I kill any process using port 3000
    And I have a rails app in "./rails-intro"
    And I install the app
    And I run a rails server
    When I run AutoGrader with "Heroku grader" strategy for <test_subject> and <spec>
    Then I should see that the results are <expected_result>
    And I should see the execution results with <test_title>
    And I kill any process using port 3000
  Examples:
    | test_title                     | test_subject                | spec                                       | expected_result       |
    | Part2: specs vs local skeleton | solutions/lib/localhost_uri | autograder/combined_rails_intro_spec.rb    | Score out of 100: 3   |

