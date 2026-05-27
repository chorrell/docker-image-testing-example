require 'serverspec'
require 'docker'
require 'node_tests'
require 'npm_tests'

tag = ENV.fetch('TARGET_HOST', nil)

describe tag.to_s do
  include Helpers

  before(:all) do
    create_image(tag)
  end

  test_node('24.13.0')

  test_npm

  after(:all) do
    delete_image
  end
end
