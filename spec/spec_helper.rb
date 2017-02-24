RSpec.configure do |c|
  c.order = :defined
  c.fail_fast = 1
  # for --only-failures
  c.example_status_persistence_file_path = './spec/reports/examples.txt'
end

def test_image
  'ruby:alpine'
end

def check_docker_available
  if 'OK' == (Docker.ping rescue nil)
    return true
  else
    warn 'Please launch dokcer daemon'
    exit(1)
  end
end

def check_test_image
  if Docker::Image.exist?(test_image)
    return true
  else
    warn "Please docker pull #{test_image}"
    exit(2)
  end
end
