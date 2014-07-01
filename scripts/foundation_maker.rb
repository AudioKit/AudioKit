#!/usr/bin/env ruby

require 'erb'
require 'pp'
require 'find'
require 'pathname'
require 'active_support/all'

def pretty_operation_list
	return_string = ""
	Find.find("../AudioKit/Operations/") do |file_path|

		if File.directory?(file_path) 
			pretty_directory = /AudioKit\/(.*)$/.match(file_path)[1]
			pretty_directory.gsub!(/\/$/,"")
			pretty_directory.gsub!(/\//," - ")
			return_string = return_string + "\n// " + pretty_directory + "\n"
		else
			if /\.h/.match(file_path)
				return_string = return_string + '#import "' + Pathname.new(file_path).basename.to_s + '"' + "\n"
			end
		end
	end
	return return_string
end

operation_file_paths = []
Find.find("../AudioKit/Operations/") do |file|
	operation_file_paths << file if  /\.h/.match(file) 
end

operation_files = operation_file_paths.map{|f| Pathname.new(f).basename }

File.open( "templates/AKFoundationTemplate.h.erb" ) { |template|
	erb = ERB.new( template.read, nil, '-' )
	File.open("AKFoundation.h", 'w') {|f| f.write(erb.result) }
	puts erb.result
}
