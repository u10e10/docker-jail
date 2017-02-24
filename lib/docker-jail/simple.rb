module DockerJail
  class Simple < Base
    using DockerJail::ClassExtensions

    # @param [String] image Container base image
    # @param [Array<String>] cmd_list Execute command and parameters
    # @param [String] user (nil) Docker container's default user is 'root:root'.
    # @param [String] cpus (nil)
    # @param [Integer] memory_mb (nil)  Memory limit in MB. 0 is unlimited
    # @param [Integer] pids_limit (nil)
    # @param [Array<String>] binds (nil) Bind mount directories
    # @param [String] workdir (nil) The working directory.
    # @param [Hash] tmpfs (nil) Mount empty tmpfs
    # @option opts [Hash] opts Other options to create Docker container
    def initialize(image:, cmd_list:, user: nil, workdir: nil, cpus: nil, memory_mb: nil,
                   pids_limit: nil, binds: nil, tmpfs: nil, **other_opts)
      mem_size = memory_mb&.*(1024**2)
      other_host_opts = other_opts.delete(:HostConfig)

      host_opts = {
        CpusetCpus: cpus,
        Memory: mem_size,
        MemorySwap: mem_size,
        PidsLimit: pids_limit,
        Binds: binds,
        Tmpfs: tmpfs,
      }.compact.merge(other_host_opts || {})

      opts = {
        Image: image,
        Cmd: cmd_list,
        User: user,
        WorkingDir: workdir,
        HostConfig: host_opts,
      }.compact.merge(other_opts)

      super(opts.merge(other_opts || {}))
    end
  end
end
