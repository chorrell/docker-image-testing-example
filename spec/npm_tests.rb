# npm tests

def test_npm
  describe command('npm version') do
    its(:exit_status) { should eq 0 }
  end

  describe command('npm install -g json') do
    its(:exit_status) { should eq 0 }
  end

  describe command('json --version') do
    its(:exit_status) { should eq 0 }
  end

  describe command("echo \'{\"foo\":\"bar\"}\' | json foo") do
    its(:stdout) { should match /bar/ }
  end
end 