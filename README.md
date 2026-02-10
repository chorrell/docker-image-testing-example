# docker-image-testing-example

This is an example of using Serverspec to test Dockerfiles

## Setup

Install Serverspec and the require gems with bundler:

```shell
bundle install
```

This example assumes you have Docker installed, running and configured.

## Usage (running the tests)

```shell
bundle exec rake
```

The above will run Serverspec and using the docker-api gem it will

- Build a Docker image from the Docker file found in the top level directories (22 and 24)
- Create a container of that image,
- Run the tests found in `spec/` on the container
- Delete the images and containers if the test was successful

The Dockerfiles are based on the official [docker-node](https://github.com/nodejs/docker-node) image.

You could also use the docker-api gem to pull existing images from the Docker hub and run tests against that image.

So for instance, a pull_image helper could look something like this:

```ruby
  def pull_image(image)

    puts "Pulling image #{image}..."
    @image = Docker::Image.create('fromImage' => image)

    set :os, :family => 'debian'
    set :backend, :docker
    set :docker_image, @image.id

    puts "Running tests..."
  end
```

## Reference

- Documentation for Serverspec can be found at <http://serverspec.org/resource_types.html>
- Documentation for the docker-api gem can be found at <https://github.com/swipely/docker-api>
