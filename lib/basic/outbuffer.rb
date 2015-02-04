module Basic
  class Outbuffer
    attr_reader :buffer
    attr_reader :overflow
    def self.instance
      @@instance ||= self.new
    end

    def initialize
      @buffer = ""
    end

    def print(string)
      @buffer << string
      if @buffer.length > 120
        @buffer = @buffer[0,120]
        @overflow  = true
        raise BufferOverflowException.new
      end
    end

    def clear
      @buffer = ""
      @overflow = false
    end

  end
end