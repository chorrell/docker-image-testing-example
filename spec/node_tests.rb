# Node tests

def test_node(version)
  describe command('node -v') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /#{version}/ }
  end
end