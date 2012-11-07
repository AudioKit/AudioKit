#!/usr/bin/env ruby

# TODO: Do not overwrite an existing file.

require 'active_support/all'
require 'erb' 

def ocsVarBestGuess(input)
	ocsVar = input[1..-1]
	ocsVar = "amplitude"       if input[1..3] == "amp" 
	ocsVar = "cutoffFrequency" if input[1..3] == "fco"
	ocsVar = "distortion"      if input[1..4] == "dist"
	ocsVar = "duration"        if input[1..3] == "dur"
	ocsVar = "frequency"       if input[1..3] == "cps" || input[1..4] == "freq"  || input[1..5] == "pitch" 
	ocsVar = "fTable"          if input[0..2] == "ifn" 
	ocsVar = "phase"           if input[1..3] == "phs" 
	ocsVar = "resonance"       if input[1..3] == "res"
	ocsVar = "sourceSignal"    if input[1..3] == "sig"
	ocsVar = "type"            if input[1..3] == "typ"
	return ocsVar
end

opcode_file = ARGV[0]
file = File.open("#{opcode_file}")

opcode_file_stub = opcode_file[0..-5]
opcode = /([A-z0-9]+)/.match(opcode_file_stub).to_s

contents = ""
file.each do |line|
  contents << line
end

# Get rid of spaces and newlines
contents.gsub!(/[ \n\\]/, "")
#puts contents

# load everything before the opcode name as outputs
outputs =  /(.+)#{opcode}/.match(contents)[1].split(",")

outputType = "OCSStereoAudioOrAudioOrControlOrConstant"
if outputs[0][0] == "i"
	outputType =  "OCSConstant"
end

if outputs[0][0] == "k"
	outputType =  "OCSControl"
end

if outputs[0][0] == "a"
	outputType = "OCSAudio"
	if outputs.count == 2
		outputType = "OCSStereoAudio"
	end
end

# load all the inputs before the first bracket, indicating optionals
inputs =  /#{opcode}([^\[]+)/.match(contents)[1].split(",")

# load the rest as optional initialization inputs
optionals = /#{opcode}[^\[]+[^,]+,(.+)/.match(contents)[1].gsub(/[\[\]\ ]/, "").split(",")

File.open( "templates/opcode_template.yaml.erb" ) { |template|
	erb = ERB.new( template.read, nil, '-' )
	File.open("#{opcode_file_stub}.yaml", 'w') {|f| f.write(erb.result) }
	puts erb.result
}