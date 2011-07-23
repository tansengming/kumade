Feature: Deploying to Heroku
  In order to easily use Heroku's services
  As a user
  I want to deploy to Heroku

  Background:
    Given a directory named "deployer"
    When I cd to "deployer"
     And I write to "Gemfile" with:
    """
    source "http://rubygems.org"
    gem "rake", "0.8.7"
    gem "kumade"
    """
    And I add "kumade" from this project as a dependency
    And I load the tasks with a stub for git push
    And I initialize a git repo
    And I commit everything in the current directory to git

  Scenario: deploy task is an alias for deploy:staging
    When I successfully run `rake deploy`
    Then the output should contain "[stub] Deployed to staging"

  Scenario: Deploying to staging
    When I successfully run `rake deploy:staging`
    Then the output should contain "[stub] Deployed to staging"

  Scenario: Deploying to production
    When I successfully run `rake deploy:production`
    Then the output should contain "[stub] Deployed to production"

  Scenario: Can't push to staging with a dirty git repo
    When I append to "Rakefile" with:
    """
    # Dirtying up your git repo
    """
    And I run `rake deploy:staging`
    Then the output should contain "Cannot deploy: repo is not clean"

  Scenario: Can't push to production with a dirty git repo
    When I append to "Rakefile" with:
    """
    # Dirtying up your git repo
    """
    And I run `rake deploy:production`
    Then the output should contain "Cannot deploy: repo is not clean"