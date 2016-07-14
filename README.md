# docker-image-testing-example

This is an exmaple of using Serverspec to test Dockerfiles

## Setup

Install Serverspec and the require gems with bundler:

```
bundle install
```

This exmaple assumes you have Docker installed, running and configured.

## Usage (running the tests)

```
cd test
rake
```

The above will run Serverspec and using the docker-api gem it will

- Build a Docker image from the Docker file found in the top level dictrories (4.4 and 6.3)
- Create a container of that image,
- Run the tests found in `spec/` on the container
- Delete the images and containers if the test was successful

The Dockerfiles are based on the offiial [docker-node](https://github.com/nodejs/docker-node) image.

You could also use the docker-api gem to pull exisiting images from the Docker hub and run tests against that image.

So for instance, a pull_image helper could look something like this:

```
  def pull_image(image)
    
    puts "Pulling image #{image}..."
    @image = Docker::Image.create('fromImage' => imge)
    
    set :os, :family => 'debian'
    set :backend, :docker
    set :docker_image, @image.id
    
    puts "Running tests..."
  end

```

## Reference

- Documentation for Serverspec can be found at http://serverspec.org/resource_types.html
- Documentation for the docker-api gem can be found at https://github.com/swipely/docker-api

