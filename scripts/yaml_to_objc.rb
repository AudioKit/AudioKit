#!/usr/bin/env ruby

# TODO: Get the indentation perfect
# TODO: Output Explorable Explanations Operation Examples and HTML
# TODO: Handle special cases like unused variables in CSound signature

require 'erb'
require 'yaml' 
require 'pp'
require 'active_support/all'

def detectType(csd_var)

	type = "AKParameter"
	
	if csd_var[0..2] == "ifn" 
		type = "AKFTable"
	elsif csd_var[0] == "a"  
		type = "AKAudio"
	elsif csd_var[0] == "k"  
		type = "AKControl"
	elsif csd_var[0] == "i"  
		type = "AKConstant"
	elsif csd_var[0] == "f"  
		type = "AKFSignal"	
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

File.open( "templates/AKOperationTemplate.h.erb" ) { |template|
	erb = ERB.new( template.read, nil, '-' )
	File.open("#{operation}.h", 'w') {|f| f.write(erb.result) }
	puts erb.result
}

File.open( "templates/AKOperationTemplate.m.erb" ) { |template|
	erb = ERB.new( template.read, nil, '-' )
	File.open("#{operation}.m", 'w') {|f| f.write(erb.result) }
	puts erb.result
}