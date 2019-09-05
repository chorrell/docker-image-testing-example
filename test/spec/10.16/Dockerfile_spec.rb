require 'serverspec'
require 'docker'
require 'node_tests'
require 'npm_tests'

tag = ENV['TARGET_HOST']

describe "#{tag}" do
  include Helpers
  
  before(:all) do
    create_image(tag)
  end

  test_node("10.16.3")

  test_npm

  after(:all) do
    delete_image
  end  

end
