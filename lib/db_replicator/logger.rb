module DbReplicator
  module Logger

    def log(before, after = '')
      before.prepend "[#{identifier}] "
      after.prepend  "[#{identifier}] "

      puts before.colorize(:yellow)
      if block_given?
        yield.tap do
          puts after.colorize(:green) unless after.blank?
        end
      end
    end

  end
end