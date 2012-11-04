#!/usr/bin/env ruby

# TODO: Get the indentation perfect
# TODO: Output Explorable Explanations Operation Examples and HTML
# TODO: Handle special cases like unused variables in CSound signature

require 'erb'
require 'yaml' 
require 'pp'
require 'active_support/all'

def detectType(csd_var)

	type = "OCSParameter"
	
	if csd_var[0..2] == "ifn" 
		type = "OCSFTable"
	elsif csd_var[0] == "a"  
		type = "OCSAudio"
	elsif csd_var[0] == "k"  
		type = "OCSControl"
	elsif csd_var[0] == "i"  
		type = "OCSConstant"
	end

	return type

end


opcode_yaml = ARGV[0]

o = YAML::load(File.open("#{opcode_yaml}"))

opcode = o["opcode"]
operation = o["operation"]
operationClass = o["operationClass"]
input_list = o["input_list"]
required_inputs = o["required_inputs"]
optional_inputs = o["optional_inputs"]
summary = o["summary"]
description = o["description"]

File.open( "templates/OCSOperationTemplate.h.erb" ) { |template|
	erb = ERB.new( template.read, nil, '-' )
	File.open("#{operation}.h", 'w') {|f| f.write(erb.result) }
	puts erb.result
}

File.open( "templates/OCSOperationTemplate.m.erb" ) { |template|
	erb = ERB.new( template.read, nil, '-' )
	File.open("#{operation}.m", 'w') {|f| f.write(erb.result) }
	puts erb.result
}