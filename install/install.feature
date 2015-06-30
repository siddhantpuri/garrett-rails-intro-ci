Feature: Installation of dependencies
  In order to check that the supplied homework can be graded by AutoGrader
  As an AutoGrader deployer
  I need to check the installation

  Scenario: Install or check skeleton
    Given that I am in the project root directory "rails-intro-ci"
    When I clone "master" branch of public skeleton "saasbook/rails-intro"
    And I install the gems from "rails-intro"
    Then I should see that there are no errors

  Scenario: Install or check AutoGraders
    Given that I am in the project root directory "rails-intro-ci"
    When I install or check "saasbook/rag" as "rag"
    And I change to branch "develop"
    And I install the AutoGrader gems
    And I run cucumber for AutoGrader
    Then I should see that there are no errors

  Scenario: Verify correct version of AutoGraders
    Given I go to the AutoGrader directory "rag"
    And it has an origin of "saasbook/rag"
    When I fetch the latest on origin branch "develop"
    Then I should see no difference

    
