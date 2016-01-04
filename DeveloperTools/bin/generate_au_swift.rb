#!/usr/bin/env ruby

require 'erb'
require 'active_support/all'

class String
  def uncapitalize
    self[0, 1].downcase + self[1..-1]
  end
end

swift_file = ARGV[0]

au_name = /AU([A-z0-9]+).swift/.match(swift_file).captures[0]

parameters = []
k_prefix = ""
name = ""
scope = ""
type = ""
min = ""
max = ""
default = ""

File.open( swift_file ).each do |line|

    regex = /^\/\/ ([A-z0-9]+), ([A-z0-9]+), ([\-0-9\.]+)\s*->\s*([\-0-9\.]+), ([\-0-9\.]+)/
    if line =~ regex
        scope   = regex.match(line).captures[0]
        type    = regex.match(line).captures[1]
        min     = regex.match(line).captures[2]
        max     = regex.match(line).captures[3]
        default = regex.match(line).captures[4]
    end

    regex = /^\/\/ ([A-z0-9]+), ([A-z0-9]+), ([\-0-9\.]+)\s*->\s*\(SampleRate\/2\), ([\-0-9\.]+)/
    if line =~ regex
        scope   = regex.match(line).captures[0]
        type    = regex.match(line).captures[1]
        min     = regex.match(line).captures[2]
        max     = "22050"
        default = regex.match(line).captures[3]
    end

    regex = /public var ([A-z0-9]+)_([A-z0-9]+)/
    if line =~ regex
        k_prefix = regex.match(line).captures[0]
        name     = regex.match(line).captures[1]

        # puts parameters
        parameters.push({
            :k_prefix => k_prefix,
            :name => name,
            :variable => name.uncapitalize,
            :scope => scope,
            :type => type,
            :min => min,
            :max => max,
            :default => default
        })
    end

end

# puts parameters

# output_folder = "../AudioKit/Common/Nodes/Effects/Distortion/AK#{au_name}/"

File.open("templates/AKAUNode.swift.erb") { |template|
    erb = ERB.new( template.read, nil, '-' )
    # File.open("#{output_folder}/AK#{au_name}.swift", 'w+') {|f| f.write(erb.result) }
    puts erb.result
}

File.open("templates/AKNodeWindow.swift.erb") { |template|
    erb = ERB.new( template.read, nil, '-' )
    # File.open("../AudioKit/OSX/AudioKit/Playgrounds/Helpers/AK#{au_name}Window.swift", 'w+') {|f| f.write(erb.result) }
    # puts erb.result
}

File.open("templates/AKNode.playground.erb") { |template|
    erb = ERB.new( template.read, nil, '-' )
    # File.open("output/AK#{au_name}.playground", 'w+') {|f| f.write(erb.result) }
    # puts erb.result
}