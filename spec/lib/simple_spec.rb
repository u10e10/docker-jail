require 'spec_helper'
require 'docker-jail'

check_docker_available
check_test_image

describe DockerJail::Simple do
  describe '#initialize keyword parameters' do
    opts = {
      image: test_image, cmd_list: ['ls'], user: 'nobody:nobody', workdir: '/tmp',
      cpus: '0', memory_mb: 10, pids_limit: 30,
      binds: ['/tmp:/tmp:ro'], tmpfs: {'/tmp/a' => 'rw,size=65536k'},
    }

    cntr = DockerJail::Simple.new(opts)
    config = cntr.json['Config']
    host_config = cntr.json['HostConfig']

    it{ expect(config['Image']).to eq opts[:image]}
    it{ expect(config['User']).to eq opts[:user]}
    it{ expect(config['Cmd']).to eq opts[:cmd_list]}
    it{ expect(config['WorkingDir']).to eq opts[:workdir]}
    it{ expect(host_config['CpusetCpus']).to eq opts[:cpus]}
    it{ expect(host_config['Memory']).to eq opts[:memory_mb]*1024**2}
    it{ expect(host_config['MemorySwap']).to eq opts[:memory_mb]*1024**2}
    it{ expect(host_config['PidsLimit']).to eq opts[:pids_limit]}
    it{ expect(host_config['Binds']).to eq opts[:binds]}
    it{ expect(host_config['Tmpfs']).to eq opts[:tmpfs]}

    cntr.delete
  end

  describe '#initialize **other_opts' do
    opts = {
      image: test_image, cmd_list: ['ls'], memory_mb: 10,

      Cmd: ['date'],
      Hostname: 'example.com',
      HostConfig: {
        MemorySwap: 30*1024**2
      }
    }

    cntr = DockerJail::Simple.new(opts)
    config = cntr.json['Config']
    host_config = cntr.json['HostConfig']

    it{ expect(config['Image']).to eq opts[:image]}
    it{ expect(config['Cmd']).to eq opts[:Cmd]}
    it{ expect(config['Hostname']).to eq opts[:Hostname]}
    it{ expect(host_config['Memory']).to eq opts[:memory_mb]*1024**2}
    it{ expect(host_config['MemorySwap']).to eq opts[:HostConfig][:MemorySwap]}
  end
end
