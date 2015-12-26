#!/usr/bin/env ruby

require 'erb'
require 'yaml'
require 'pp'
require 'active_support/all'
require 'action_view'
require 'fileutils'

####################
# Helper Functions #
####################

def new_partial(template, name)
	ERB.new(File.new("templates/#{template}/_#{name}.erb").read, nil, '-' ).result
end

def ak_pad(var)
	length = ($longest_ak_variable.length - var.length).abs
	length = length - 2 if var == "input"
	" " * length
end

def wrap(str, indent="")
	ActionView::Base.new.word_wrap(str, :line_width => 76).gsub("\n", "\n" + indent + "/// " )
end

################
# YAML Parsing #
################
opcode_yaml = ARGV[0]
o = YAML::load(File.open("#{opcode_yaml}"))

output_folder       = o["installation-directory"]
sp_module           = o["sporth-module"] || o["sp-module"]
node                = o["node"]
akalias             = o["akalias"]
four_letter_code    = o["four-letter-code"]
one_word_desc       = o["one-word-description"]
description         = wrap(o["description"], "    ")
summary             = o["summary"]
inputs	            = o["inputs"].to_a
tables              = o["tables"].to_a
parameters          = o["parameters"].to_a
constants           = o["constants"].to_a
constant_parameters = o["constant-parameters"].to_a
presets             = o["presets"].to_a

############################
# Set Up Helpful Variables #
############################

input_count  = o["input-count"].to_i
input_count  = inputs.count 	if input_count == 0
output_count = [o["output-count"].to_i, 1].max
puts "input count  = " + input_count.to_s
puts "output count = " + output_count.to_s


###############
# File Output #
###############

# Set up the output folder relative to the current directory and create it if necessary
output_folder = "../AudioKit/Common/Operations/#{output_folder}/"
FileUtils.mkdir_p(output_folder) unless File.directory?(output_folder)

File.open("templates/AKOperation.swift.erb") { |template|
	erb = ERB.new( template.read, nil, '-' )
	File.open("#{output_folder}/#{akalias}.swift", 'w+') {|f| f.write(erb.result) }
	# puts erb.result
}


# puts "presets:"
# puts "- name: {"
# puts "  comment: \"\","

# if parameters.count > 0
# 	puts "  parameters: {"
# 	parameters.each do |p|
# 		p.each do |sp_var, data|
# 			puts "    " + data["ak-variable"].to_s + ": value,"
# 		end
# 	end
# 	puts "  },"
# end
# if constants.count > 0
# 	puts "  constants: {"
# 	constants.each do |p|
# 		p.each do |sp_var, data|
# 			puts "    " + data["ak-variable"].to_s + ": value,"
# 		end
# 	end
# 	puts "  }"
# end
# puts "}"
