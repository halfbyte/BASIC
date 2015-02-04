$LOAD_PATH.unshift("./lib")
require 'rubygems'
require 'bundler/setup'
require 'chatterbot/dsl'
require 'basic/interpreter'

puts "STARTING BASICbot"

OUT = Basic::Outbuffer.instance


if ARGV[0] == 'debug'
  cmd ||= lambda { Readline.readline('> ',true) }
  Basic::Program.clear
  print "\nREADY\n"
  while line = cmd.call()
    begin
      if Basic::Interpreter.run_line(line)
        print ">>>" + OUT.buffer + "<<<"
      end
    rescue SyntaxError => e
      puts e.message
    rescue NoMethodError => e
      puts "?DOES NOT COMPUTE"
    end
  end
else
  tweet "SYSTEM RESTART #{Time.now.strftime("%H:%M %Y-%m-%d")}.\nREADY."
  Basic::Program.clear
  streaming do
    puts "run"
    replies do |tweet|
      puts tweet.text
      match = tweet.text.upcase.match(/@PUBLICBASIC (.*)/)
      if match
        begin
          if Basic::Interpreter.run_line(match[1])
            puts OUT.buffer
            puts OUT.buffer.length
            if reply "#USER# #{OUT.buffer}", tweet

            else
              puts "Couldn't tweet"
            end
            OUT.clear
          end
        rescue SyntaxError => e
          reply "#USER# #{e.message}", tweet
        rescue NoMethodError => e
          reply "#USER# ?DOES NOT COMPUTE", tweet
        end
      end
      #reply "#USER# Thanks for contacting me!", tweet
    end
  end
end