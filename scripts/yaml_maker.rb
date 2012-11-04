#!/usr/bin/env ruby

# TODO: Guess OCS Variable names from the Csound counterparts xcps, xfreq => frequency xamp => amplitude, ifn =>fTable, etc. 
# TODO: Guess OCSParameter type (Audio, Control, etc.) from first letter of the output

require 'active_support/all'
require 'erb' 

opcode_file = ARGV[0]
file = File.open("#{opcode_file}")

opcode_file_stub = opcode_file.sub(/.txt/) { "" }
opcode = /([A-z]+)/.match(opcode_file_stub).to_s

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
	File.open("#{opcode_file_stub}.yaml", 'w') {|f| f.write(erb.result) }
	puts erb.result
}