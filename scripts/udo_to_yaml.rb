#!/usr/bin/env ruby

opcode_file = ARGV[0]
file = File.open("#{opcode_file}")

opcode_file_stub = opcode_file.sub(/.udo/) { "" }
opcode = /([A-z0-9]+)/.match(opcode_file_stub).to_s

contents = ""
file.each do |line|
  contents << line
end

contents = contents.match(/SYNTAX\n([A-z\t, ^]+)/)[1]
puts contents