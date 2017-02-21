module DockerJail
  module ClassExtensions
    refine Hash do

      break if 2.4 <= RUBY_VERSION.to_f

      def compact!
        delete_if{ |k, v| v.nil? }
      end

      def compact
        h = self.dup
        h.delete_if{ |k, v| v.nil? }
      end
    end
  end
end
