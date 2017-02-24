require 'docker-jail/helper.rb'

describe 'Ruby version compatibility' do
  class Test
    using DockerJail::ClassExtensions

    def self.call_compact(h)
      h.compact
    end

    def self.call_compact!(h)
      h.compact!
      h
    end
  end

  data0 = [{key: nil}, {key0: nil, key1: nil}]
  data1 = [{key: 0}, {key: {}}, {key: []}, {key0: 0, key1: nil}]

  describe 'Hash#compact' do
    # compact empty
    data0.each do |h|
      it{
        h_copy = h.dup
        expect(Test.call_compact(h)).to be_empty
        expect(h).to eq h_copy
      }
    end

    # compact not empty
    data1.each do |h|
      it{
        h_copy = h.dup
        expect(Test.call_compact(h)).not_to be_empty
        expect(h).to eq h_copy
      }
    end
  end

  describe 'Hash#compact!' do
    # compact! empty
    data0.each do |h|
      it{
        h_copy = h.dup
        expect(Test.call_compact!(h)).to be_empty
        expect(h).to be_empty
        expect(h).not_to eq h_copy
      }
    end

    # compact! not empty
    context do
      tmp = data1[0].dup
      it {expect(Test.call_compact!(tmp)).to be tmp}
      it {expect(tmp).to eq(data1[0])}
    end

    context do
      tmp = data1[1].dup
      it {expect(Test.call_compact!(tmp)).to be tmp}
      it {expect(tmp).to eq(data1[1])}
    end

    context do
      tmp = data1[2].dup
      it {expect(Test.call_compact!(tmp)).to be tmp}
      it {expect(tmp).to eq(data1[2])}
    end

    context do
      tmp = data1[3].dup
      it {expect(Test.call_compact!(tmp)).to be tmp}
      it {expect(tmp).to eq({key0: 0})}
    end
  end
end
