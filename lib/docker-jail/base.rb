require 'docker'
require 'timeout'

module DockerJail
  # Execute command in jail.
  class Base
    using DockerJail::ClassExtensions

    @@base_opts = {
        # Image:  'centos',
        # Cmd:    ['ls', '-a'],
        # User:   'user:group',  # (defaults: root:root)
        OpenStdin:       true,
        StdinOnce:       true,
        Tty:             false,
        AttachStdin:     true,
        AttachStderr:    true,
        NetworkDisabled: true,
        # WorkingDir: '/',
        HostConfig: {
          # CpusetCpus:     '0'  # (String) (defaults: unset) e.g. '0', '0,2', '0-3',
          # Memory:          0,  # (defaults: 0 unlimited) Memory byte size
          PidsLimit:        15,
          NetworkMode:      'none',
          CapDrop:          'all',
          ReadonlyRootfs:   true,
          OomKillDisable:   false,
          AutoRemove:       false,
          LogConfig: {Type: 'none'}
          # Binds: [],
          # Tmpfs: {},
        }
    }.freeze

    attr_reader :container, :out, :err


    def self.get_all()
      Docker::Container.all(all:true)
    end

    def self.remove_all()
      Docker::Container.all(all:true).each{|c| c.delete(force:true) }
    end

    def self.build_container(**opts)
      return Docker::Container.create(@@base_opts.merge(opts))
    end

    # @option opts [Hash] opts options to create Docker container
    # @see https://docs.docker.com/engine/api/v1.26/ Docker API Reference
    # @example
    #   DockerJail::Base.new(Image: 'centos', Cmd: ['ls', '-a'], HostConfig: {Memory: 10*1024})
    def initialize(**opts)
      @container = self.class.build_container(opts.compact)
    end

    # Run container
    # @param [StringIO] input Give input stream to stdin
    # @yieldparam [String] stream_name
    # @yieldparam [String] stdout/stderr string(partial)
    # @return [String, String] stdout and stderr
    def run(input=nil, &block)
      @out, @err = @container.tap(&:start).attach(logs: true, tty: false, stdin: input, &block)
    end

    # Run container with a time limit.
    #   Container run in the sub thread.
    #   the timeout value contain the container up time.
    # @param (see #run)
    # @param [Numeric] timeout
    #   execution time limit(seconds).
    #   It's different from StopTimeout of Docker
    # @yieldparam (see #run)
    # @return (see #run)
    # @raise [Timeout::Error] When container run timeout, raise Timeout::Error
    def run_timeout(timeout, input=nil, &block)
      # Main thread
      Timeout.timeout(timeout) do
        # Sub thread
        return run(input, &block)
      end
    rescue Timeout::Error
      @timeout = true
    end

    # Force delete container
    def delete
      @container.delete(force: true)
    end

    # @return [nil] Time unlimited
    # @return [true] Time limit exceeded
    # @return [false] Finished within time limit
    def timeout?
      @timeout
    end

    def json
      container.json
    end

    def state
      json['State']
    end

    # Memory limit exceeded
    # @return [Bool]
    def oom_killed?
      state['OOMKilled']
    end

    # @return [Integer]
    def exit_code
      state['ExitCode']
    end

    # @return [Time]
    def started_at
      Time.parse(state['StartedAt'])
    end

    # @return [Time]
    def finished_at
      Time.parse(state['FinishedAt'])
    end
  end
end
