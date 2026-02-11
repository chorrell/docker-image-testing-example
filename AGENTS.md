# AGENTS.md

Instructions for AI coding agents working on this project.

## Project Overview

This is a Serverspec-based testing framework for validating Docker images.
The project tests Node.js Docker images built from custom Dockerfiles by
creating containers, running Serverspec tests against them, and cleaning up
resources.

**Tech Stack:**

- Ruby 3.4+ and Ruby 4.0+
- Serverspec 2.43+
- Docker API gem 2.4+
- RSpec 3.13+
- Docker BuildKit

**Current Node.js versions tested:**

- Node.js 22.22.0 (Maintenance LTS)
- Node.js 24.13.0 (Active LTS)

## Setup Commands

```bash
# Install dependencies locally (no sudo required)
bundle install

# Docker BuildKit is enabled by default in Rakefile
# Verify Docker is running
docker info
```

## Running Tests

```bash
# Run all tests in parallel (~18 seconds)
bundle exec rake

# Run tests for a specific Node.js version
bundle exec rspec spec/22/Dockerfile_spec.rb
bundle exec rspec spec/24/Dockerfile_spec.rb

# Run with verbose output
bundle exec rake --trace
```

## Project Structure

```text
.
├── 22/                          # Node.js 22 Dockerfile
├── 24/                          # Node.js 24 Dockerfile
├── spec/
│   ├── 22/Dockerfile_spec.rb   # Tests for Node.js 22
│   ├── 24/Dockerfile_spec.rb   # Tests for Node.js 24
│   ├── spec_helper.rb          # Helper methods (create_image, delete_image)
│   ├── node_tests.rb           # Shared Node.js version tests
│   └── npm_tests.rb            # Shared npm tests
├── Rakefile                     # Test runner with parallel execution
├── Gemfile                      # Ruby dependencies
└── .github/workflows/ruby.yml   # CI with Ruby 3.4 & 4.0 matrix
```

## Development Workflow

### Adding a New Node.js Version

1. Create new directory: `mkdir XX/` (where XX is the version)
2. Copy Dockerfile from existing version and update `NODE_VERSION`
3. Create test spec: `spec/XX/Dockerfile_spec.rb`
4. Update Rakefile to include new task
5. Test locally: `bundle exec rake`
6. Update README.md to mention new version

### Modifying Dockerfiles

- Always update the `NODE_VERSION` environment variable
- Verify GPG keys are current from nodejs/docker-node
- Test on both amd64 and arm64 if possible
- Use Debian trixie-slim as base image

### Updating Dependencies

```bash
# Update specific gem
bundle update <gem-name>

# Update all gems (be careful)
bundle update

# Always remove BUNDLED WITH section from Gemfile.lock for CI compatibility
```

## Documentation Standards

### Markdown Linting

All markdown files must pass markdownlint validation before committing.

```bash
# Check all markdown files
npx markdownlint-cli *.md

# Auto-fix issues where possible
npx markdownlint-cli --fix *.md
```

**Configuration**: See `.markdownlint.json` for project rules.

**Key Rules**:

- Line length: 120 characters max (code blocks excluded)
- Blank lines around headings and lists
- Language specified for fenced code blocks
- No bare URLs (use markdown links)
- Use proper headings (not bold text as headings)

## Testing Instructions

### What Tests Validate

1. **Node.js Version**: Correct version is installed
2. **npm Functionality**: npm commands work correctly
3. **Global Package Installation**: Can install global npm packages
4. **Package Execution**: Installed packages run correctly

### Writing Tests

- Use shared test helpers in `spec/node_tests.rb` and `spec/npm_tests.rb`
- Tests run inside Docker containers via docker-api gem
- Each test spec must include proper setup/teardown:

```ruby
before(:all) do
  create_image(tag)  # Builds Docker image
end

after(:all) do
  delete_image  # Cleans up containers and images
end
```

### Test Execution

- Tests run in PARALLEL by default (Rake multitask)
- Each test gets isolated `ENV['TARGET_HOST']`
- Containers are automatically cleaned up after tests
- Images are removed only if tests pass

## Code Style and Conventions

### Ruby Style

- Use 2 spaces for indentation
- Follow existing patterns in spec files
- Use double quotes for strings
- Keep helper methods in `spec_helper.rb`

### Serverspec Patterns

```ruby
# Use shared test methods
test_node("24.13.0")  # Preferred
test_npm              # Preferred

# Resource types commonly used
describe command("node --version")
describe package("curl")
describe file("/usr/local/bin/node")
```

### Dockerfile Conventions

- Use multi-line RUN with `&&` for layer efficiency
- Always verify GPG signatures
- Clean up apt cache: `rm -rf /var/lib/apt/lists/*`
- Install CA certificates for HTTPS downloads

## CI/CD Configuration

### GitHub Actions Matrix

Tests run on:

- Ruby 3.4 (current stable)
- Ruby 4.0 (latest stable)

Both versions must pass before merge.

### Environment Variables

- `DOCKER_BUILDKIT=1`: Always enabled (set in workflow and Rakefile)
- `TARGET_HOST`: Set per test for isolation (handled automatically)

## Dos and Don'ts

### DO ✅

- Test all changes locally before committing
- Run full test suite: `bundle exec rake`
- Lint markdown files: `npx markdownlint-cli *.md`
- Keep Node.js versions on LTS releases
- Update README.md when changing versions
- Use version pinning in Gemfile (`~>` operator)
- Clean up Docker resources properly
- Use parallel test execution (Rake multitask)
- Handle errors gracefully in helper methods

### DON'T ❌

- Don't stop all Docker containers (only test containers)
- Don't use `sudo` for bundle install (use local path)
- Don't hardcode image IDs (use @image variable)
- Don't skip the `after(:all)` cleanup block
- Don't add BUNDLED WITH section to Gemfile.lock
- Don't test EOL (End of Life) Node.js versions
- Don't modify .bundle/config (project-level config)
- Don't disable Docker BuildKit without good reason

## Git Commit Guidelines

### Commit Message Format

```text
<type>: <short summary>

<detailed description>

<optional breaking changes>

Co-authored-by: <AI agent or human collaborator>
```

### Types

- `fix`: Bug fixes
- `feat`: New features
- `perf`: Performance improvements
- `test`: Test-only changes
- `docs`: Documentation updates
- `chore`: Dependency updates, tooling

### Example

```text
feat: Add Node.js 26 LTS support

- Create 26/Dockerfile with NODE_VERSION=26.x.x
- Add spec/26/Dockerfile_spec.rb with version tests
- Update Rakefile to include node26 task
- Update README.md to list version 26

Tests pass on Ruby 3.4 and 4.0.
```

## Pull Request Guidelines

1. **One change per PR**: Keep PRs focused
2. **Test coverage**: Ensure all tests pass locally and in CI
3. **Update docs**: Update README.md if user-facing changes
4. **Commit history**: Squash commits for cleaner history
5. **Co-authorship**: Add co-author tags for collaborators

## Security Considerations

### Dockerfile Security

- Always verify GPG signatures for Node.js downloads
- Use specific Debian versions (not `latest`)
- Minimize installed packages
- Clean up package manager cache

### Dependency Security

- Keep gems updated for security patches
- Review CVEs for docker-api and other dependencies
- Use `bundle audit` to check for vulnerabilities

### Container Isolation

- Tests create isolated containers per version
- Containers are removed after tests complete
- Only stop containers created by tests (not system-wide)

## Debugging

### Common Issues

#### Tests fail with "container not found"

- Check that Docker daemon is running
- Verify container cleanup in after(:all) block

#### Image build fails

- Verify Node.js version exists on nodejs.org
- Check GPG key servers are accessible
- Review Docker BuildKit logs

#### Bundler version conflicts

- Remove BUNDLED WITH section from Gemfile.lock
- Let CI use its native Bundler version

#### Performance Issues

- Ensure Docker BuildKit is enabled
- Verify parallel execution (multitask) is working
- Check if Docker daemon has resource constraints

### Debug Commands

```bash
# List Docker images created by tests
docker images | grep test

# Check running containers
docker ps -a

# View Docker BuildKit cache
docker buildx du

# Run with verbose Rake output
bundle exec rake --trace

# Run single test with RSpec output
bundle exec rspec spec/24/Dockerfile_spec.rb --format documentation
```

## Resources

- **Serverspec Documentation**: <http://serverspec.org/resource_types.html>
- **Docker API Gem**: <https://github.com/swipely/docker-api>
- **Node.js Releases**: <https://nodejs.org/en/about/previous-releases>
- **Ruby Releases**: <https://www.ruby-lang.org/en/downloads/releases/>

## Questions?

When working on this project:

1. Check existing patterns in similar files
2. Run tests locally before committing
3. Review CI output for multi-version compatibility
4. Keep changes focused and well-tested

---

**Note**: For historical information about AI contributions to this project, see [AI-CONTRIBUTIONS.md](./AI-CONTRIBUTIONS.md).
