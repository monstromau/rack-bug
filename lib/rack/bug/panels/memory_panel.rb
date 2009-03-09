# 
module Rack
  module Bug
    
    class MemoryPanel < Panel
      
      def name
        "memory"
      end
      
      def before(env)
        @original_memory = `ps -o rss= -p #{$$}`.to_i
      end
      
      def after(env, status, headers, body)
        @total_memory = `ps -o rss= -p #{$$}`.to_i
        @memory_increase = @total_memory - @original_memory
      end
      
      def heading
        "#{@memory_increase} KB used, #{@total_memory} KB total"
      end

      def has_content?
        false
      end
      
    end
    
  end
end