require 'open3'

# Configure path from homework to rag folder, or can be absolute
HW_RAG_PATH = 'rag'
# path from rag to the homework folder, or use absolute
RAG_HW_PATH = '..'

Given(/^I have the public skeleton "(.*?)" in "(.*?)"$/) do |skel_repo, dir|
  @cloned = dir+ '/' + skel_repo.split('/')[1]
  expect(Dir).to exist(@cloned)
end

And /^it is on the "(.*)" branch$/ do |branch|
  run_process('git branch', @cloned)
  expect(@test_output).to include("* #{branch}")
end

# relative to pwd which should be bdd-cucumber-ci
Given /^I have the reference application in "([^"]*)"$/ do |path|
  @reference_app_path = "#{path}"
end

Given /I have the homework in "([^"]*)"/ do |path|
  @hw_path = path
end

Given /^I have prepared the reference application$/ do
  #cleanup-restore first from unchanging backups in case of bad exit last run
  steps "Then I restore the reference application"

  ## bundle install not needed here or install.feature
  #cli_string = 'bundle install'
  #cli_string += ' && bundle exec rake db:migrate'
  #cli_string += ' && bundle exec rake db:test:prepare'
  #run_process(cli_string, @reference_app_path)
end

Given /^I have mutated the reference application$/ do
  # always cp -f from unchanging backups
  cli_string = "cp -f #{@hw_path}/autograder/movies_controller.rb.MUTATOR #{@reference_app_path}/app/controllers/movies_controller.rb"
  run_process(cli_string, '.')
end

## When steps

When(/^I run AutoGrader for (.*) and (.*)$/) do |test_subject, spec|
  run_ag("#{@hw_path}/#{test_subject}", "#{@hw_path}/#{spec}")
end

When(/^I run AutoGrader with "([^"]*)" strategy for (.*) and (.*)$/) do |strategy, test_subject, spec|
  run_ags("#{@hw_path}/#{test_subject}", "#{@hw_path}/#{spec}", strategy)
end

def run_ags(subject, spec, strategy = 'Rspec grader')
  cli_string = case strategy
                 when 'Coverage grader' then
                   "./grade4 #{RAG_HW_PATH}/#{subject} #{RAG_HW_PATH}/#{spec}"
                 when 'Rspec grader' then
                   "./grade #{RAG_HW_PATH}/#{subject} #{RAG_HW_PATH}/#{spec}"
                 when 'Heroku grader' then
                   uri = get_uri_from_file("./#{subject}")
                   "./grade_heroku #{uri} #{RAG_HW_PATH}/#{spec}"
                 when 'Feature Grader' then
                   "./grade3 -a #{RAG_HW_PATH}/#{@reference_app_path} #{RAG_HW_PATH}/#{subject} #{RAG_HW_PATH}/#{spec}"
               end
  run_process cli_string
end
def get_uri_from_file(path)
  File.read(path).strip
end
## Then steps

Then(/^I should see that the results are (.*)$/) do |expected_result|
  expect(@test_output).to match /#{expected_result}/
end

Then /^I should see the execution results with (.*)$/ do |test_title|
  success = @test_status.success? ? 'Success' : 'Failure'
  puts success + '!'
end

Then /^I restore the reference application$/ do
  plain_controller = "#{@hw_path}/autograder/movies_controller.rb.PLAIN"
  ref_app_controller = "#{@reference_app_path}/app/controllers/movies_controller.rb"
  run_process("cp -f #{plain_controller} #{ref_app_controller}", '.')
  expect(File.read "#{ref_app_controller}").to eql File.read("#{plain_controller}")
end


def run_ag(subject, spec)
  run_process "./grade3 -a #{RAG_HW_PATH}/#{@reference_app_path} #{RAG_HW_PATH}/#{subject} #{RAG_HW_PATH}/#{spec}"
end

def run_process(cli_string, dir=HW_RAG_PATH)
  @test_output, @test_errors, @test_status = Open3.capture3(
      {'BUNDLE_GEMFILE' => 'Gemfile'}, cli_string, :chdir => dir
  )
  puts (cli_string +
      @test_output +
      @test_errors +
      @test_status.to_s) unless @test_status.success? #and @test_errors.empty?
end
