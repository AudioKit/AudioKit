#!/usr/bin/env ruby

require 'active_support/all'
require 'erb' 

opcode = ARGV[0]

file = File.open("#{opcode}.txt")
contents = ""
file.each do |line|
  contents << line
end

# Get rid of spaces and newlines
contents.gsub!(/[ \n\\]/, "")
#puts contents

# load everything before the opcode name as outputs
outputs =  /(.+)#{opcode}/.match(contents)[1].split(",")

# load all the inputs before the first bracket, indicating optionals
inputs =  /#{opcode}([^\[]+)/.match(contents)[1].split(",")

# load the rest as optional initialization inputs
optionals = /#{opcode}[^\[]+[^,]+,(.+)/.match(contents)[1].gsub(/[\[\]\ ]/, "").split(",")

File.open( "templates/opcode_template.yaml.erb" ) { |template|
	erb = ERB.new( template.read )
	File.open("#{opcode}.yaml", 'w') {|f| f.write(erb.result) }
}