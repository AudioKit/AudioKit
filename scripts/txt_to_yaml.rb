#!/usr/bin/env ruby

# TODO: Do not overwrite an existing file.

require 'active_support/all'
require 'erb' 

def audioKitNameBestGuess(input)
	audioKitName = input[1..-1]
	audioKitName = "amplitude"       if input[1..3] == "amp" 
	audioKitName = "cutoffFrequency" if input[1..3] == "fco"
	audioKitName = "distortion"      if input[1..4] == "dist"
	audioKitName = "duration"        if input[1..3] == "dur"
	audioKitName = "frequency"       if input[1..3] == "cps" || input[1..4] == "freq"  || input[1..5] == "pitch" 
	audioKitName = "fTable"          if input[0..2] == "ifn" 
	audioKitName = "phase"           if input[1..3] == "phs" 
	audioKitName = "resonance"       if input[1..3] == "res"
	audioKitName = "audioSource"     if input[1..3] == "sig"
	audioKitName = "type"            if input[1..3] == "typ"
	return audioKitName
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

outputType = "AKStereoAudioOrAudioOrControlOrConstant"
if outputs[0][0] == "i"
	outputType =  "AKConstant"
end

if outputs[0][0] == "k"
	outputType =  "AKControl"
end

if outputs[0][0] == "a"
	outputType = "AKAudio"
	if outputs.count == 2
		outputType = "AKStereoAudio"
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