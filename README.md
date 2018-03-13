# DockerJail

It's easy to make a jail with Docker.  

## Installation

```bash
gem install docker-jail
```

## Documents

This gem is documented by YARD.  

```bash
yard server --gems
```

### See
[Docker Engine API](https://docs.docker.com/engine/api/v1.26/)  
[docker-api for ruby](https://github.com/swipely/docker-api)  


## Usage

```ruby
require 'docker-jail'
rsecoundequire 'pp'

# options
image      = 'ruby:alpine'
user       = 'nobody:nobody'
pids_limit = 10
cpus       = '0' # string
memory_mb  = 100 # 100MB
timeout    = 10  # 10 seconds
input      = StringIO.new('10')
tmpfs      = {'/tmp/a': 'rw,size=65536k'}
cmd_list   = ['ruby', '-e', 'puts(gets().to_i*2)']

opts = {cmd_list: cmd_list, image: image, user: user, workdir: '/tmp',
        cpus: cpus, memory_mb: memory_mb, pids_limit: pids_limit, tmpfs: tmpfs}

# Create jail
puts 'Create a container'
jail = DockerJail::Simple.new(opts)

# Run with a time limit
puts 'Run with a time limit'
jail.run_timeout(timeout, input) # {|s,c| puts "#{s}: #{c}"}

# Results
puts "-------------------------"
puts "Exit:        #{jail.exit_code}"
puts "Time over:   #{jail.timeout?}"
puts "Memory over: #{jail.oom_killed?}"

print 'Stdout: '
p jail.out
print 'Stderr: '
p jail.err
print 'State: '
p jail.state

# require 'pry'
# binding.pry

# Delete jail
puts 'Delete force'
jail.delete
```


## KnowHow


### Share cpu resources equally 
Use `cpus` options.  
If your machine has Intel Hyper-Threading Technology,
You can share equally by setting two core id to `cpus`.  
e.g. `'0,1' `  

##### Check core id.  

```bash 
cat /proc/cpuinfo | egrep 'process|core id' 
```


### Limit the time

The docker-jail has two ways.  

* First way: use `DockerJail::Base#run_timeout` method.  
  This method can limit container execution time.  
  But container execution time contains container up/down time.  

* Second way: use `timeout` command in the container.  
    But there may be cases where the container don't have the `timeout` command.  



### Measure the time 

Use `time` command in the container.  
You can get result of the `time` command from stderr.  


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
