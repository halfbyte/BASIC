require "readline"
require "basic/program"
require "basic/compiler"
require "basic/lexer"
require "basic/outbuffer"

class Array
  def split(delim)
    self.inject([[]]) do |c, e|
       if e == delim
         c << []
       else
         c.last << e
       end
       c
    end
  end
end

class String
  def strip_str(str)
    gsub(/^#{str}|#{str}$/, '')
  end
end

class Fixnum
  def /(other)
    self.to_f / other
  end
end

class FalseClass
  define_method :"!" do
    true
  end

  define_method :"||" do |other|
    self || other
  end
end

class TrueClass
  define_method :"!" do
    false
  end
end

module Basic
  module Interpreter



    def define(number,tokens)
      commands = tokens.split(':')
      commands.each_with_index do |c,segment|
        method_body = Compiler.compile(c,number,segment)
        Program.define(number,segment,c,method_body)
      end
    rescue SyntaxError => e
      raise SyntaxError.new("SYNTAX ERROR IN LINE #{number}:\n#{e.message}\n#{tokens.join(" ")}")
    end

    def compile(number,tokens)
      if tokens.empty?
        Program.remove(number)
      else
        define number,tokens
      end
      return false # compilation does not need feedback
    end

    def execute(line,rest)
      case line
      when "RUN"
        Program.run *rest
        return true
      when "LIST"
        Program.list
        return true
      when "RENUMBER"
        Program.renumber *rest
        return false
      else
        raise NoMethodError.new
      end
      return false
    end

    def run_line(line)
      first,*rest = read(line)
      puts first, rest.inspect
      if first =~ /\d+/
        compile first.to_i, rest
      else
        execute first,rest or return
      end
    end

    def reader(cmd)
      while line = cmd.call()
        first,*rest = read(line)
        puts first, rest.inspect
        if first =~ /\d+/
          compile first.to_i, rest
        else
          execute first,rest or return
        end
      end
    end

    def run(cmd=nil)
      cmd ||= lambda { Readline.readline('> ',true) }
      Program.clear
      print "\nREADY\n"
      reader cmd
    end

    include Lexer
    extend self
  end
end
