# docker-image-testing-example

This is an example of using Serverspec to test Dockerfiles

## Setup

This example assumes you have Docker installed, running and configured.

### Ruby

This project uses [rbenv](https://github.com/rbenv/rbenv) to manage Ruby versions.
Install it and the required Ruby version:

```shell
brew install rbenv ruby-build
rbenv install   # installs the version from .ruby-version
```

Add rbenv to your shell (add to `~/.zshrc` or `~/.bashrc`):

```shell
eval "$(rbenv init - zsh)"
```

### Dependencies

Install gems with bundler:

```shell
bundle install
```

### Pre-commit Hooks

Install [pre-commit](https://pre-commit.com/) and set up the hooks:

```shell
brew install pre-commit
pre-commit install
```

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
