require 'spec_helper'
require 'docker-jail'

check_docker_available
check_test_image

describe DockerJail::Base do
  let(:json){ cntr.json }
  let(:cntr){ DockerJail::Base.new({Image: test_image}.merge(opts))}
  let(:config){ json['Config'] }
  let(:host_config){ json['HostConfig'] }
  let(:exit_code){ cntr.exit_code }

  after{ cntr.delete }

  describe '#initialize' do
    let(:opts){ {Cmd: ['ls'], HostConfig: { Memory: 10*1024**2 }} }

    it{ expect(config['Image']).to eq test_image}

    it{ expect(host_config['Memory']).to eq opts[:HostConfig][:Memory]}
  end

  describe '#run' do
    before{ cntr.run(input)}
    let(:input){nil}
    let(:opts){ {Cmd: ['ruby']+cmd_arg} }

    context 'success' do
      let(:cmd_arg){['--version']}
      it{ expect(cntr.exit_code).to eq 0}
    end

    context 'failure' do
      let(:cmd_arg){['--invalid-option']}
      it{ expect(cntr.exit_code).to eq 1}
    end

    context 'timeout? is nil' do
      let(:cmd_arg){['--version']}
      it{ expect(cntr.timeout?).to be nil}
    end

    context 'get stdout' do
      let(:cmd_arg){['-e', 'puts("output")']}
      it{ expect(cntr.out).to eq ["output\n"]}
    end

    context 'get stderr' do
      let(:cmd_arg){['-e', 'warn("error")']}
      it{ expect(cntr.err).to eq ["error\n"]}
    end

    context 'give input' do
      let(:cmd_arg){['-e', 'puts gets.to_i*10']}
      let(:input){StringIO.new('12')}
      it{
        expect(cntr.exit_code).to eq 0
        expect(cntr.out).to eq ["120\n"]
      }
    end
  end

  describe '#run_timeout' do
    before{ cntr.run_timeout(timeout, input)}
    let(:timeout){1}
    let(:input){nil}

    context 'within the timeout' do
      let(:opts){ {Cmd: ['ls']} }
      it {expect(cntr.timeout?).to be false}
    end

    context 'within the timeout with input' do
      let(:opts){ {Cmd: ['ruby', '-e', 'puts gets.to_i*10']} }
      let(:input){StringIO.new('12')}
      it{ expect(cntr.timeout?).to be false}
    end

    context 'time over' do
      let(:opts){ {Cmd: ['sleep', '1']} }
      it{ expect(cntr.timeout?).to be true}
    end

    context 'time over with input' do
      let(:opts){ {Cmd: ['ruby', '-e', 'puts gets.to_i*10; sleep(2)']} }
      let(:input){ StringIO.new('12')}
      it{ expect(cntr.timeout?).to be true}
    end
  end

  describe 'limits' do
    let(:opts){ {Cmd: ['ruby']+cmd_arg, HostConfig: {Memory: 5*1024**2}} }

    # take long time
    context 'memory' do
      let(:cmd_arg){['-r', 'securerandom', '-e', '"a"*(5*1024**2)']}
      before{cntr.run}
      it{ expect(cntr.oom_killed?).to be true}
    end
  end
end
