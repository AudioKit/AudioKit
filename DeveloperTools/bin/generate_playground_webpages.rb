#!/usr/bin/env ruby
require 'pp'
require 'active_support/all'
require 'action_view'
require 'fileutils'
require 'pathname'
require 'redcarpet'

def new_partial(template, name)
    ERB.new(File.new("templates/#{template}/_#{name}.erb").read, nil, '-' ).result
end

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

# Set up the output folder relative to the current directory and create it if necessary
output_folder = "../../audiokit.github.io/playgrounds/v3/"
# FileUtils.mkdir_p(output_folder) unless File.directory?(output_folder)

skippable_lines = ["//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)", "//: ---"]

index = "---\n"
index << "layout: section_index\n"
index << "header: Playgrounds\n"
index << "title: Index\n"
index << "permalink: /playgrounds/v3/\n"
index << "---\n\n<ol>"

page_folders = ["../AudioKit/iOS/AudioKit/AudioKit.playground/Pages/*", "../AudioKit/OSX/AudioKit/Playgrounds/AudioKit for OSX.playground/Pages/*" ]

page_folders.each_with_index do |folder, i|
    subfolder_prefix = i==0 ? "iOS" : "OSX"
    index << "<h4>#{subfolder_prefix} Playgrounds</h4><ol>"
    Dir.glob(folder) do |playground_page|
        playground_page_title = File.basename(playground_page, ".xcplaygroundpage")
        index << "<li><a href=\"#{subfolder_prefix}/#{playground_page_title}/\">#{playground_page_title}</a></li>"
        swift = File.open(playground_page + "/Contents.swift")
        results = "---\n"
        results << "layout: section_index\n"
        results << "header: Playgrounds\n"
        results << "title: #{playground_page_title}\n"
        results << "permalink: /playgrounds/v3/#{subfolder_prefix}/#{playground_page_title}\n"
        results << "---\n\n"

        markdown_block = ""
        code_block = ""
        swift.each {|swift_line|
            next if skippable_lines.include? swift_line.strip()
            if swift_line[0..2] == "//:" then
                results << "\n{% highlight ruby %}" + code_block + "{% endhighlight %}\n" if !code_block.empty?
                renderable_line = swift_line[3..-1]
                pp
                renderable_line = "<h3>#{renderable_line[4..-1]}</h2>" if renderable_line[0..3] == " ## "
                renderable_line = "<h4>#{renderable_line[5..-1]}</h3>" if renderable_line[0..4] == " ### "
                markdown_block << renderable_line
                code_block = ""
            else
                results << markdown.render(markdown_block) if !markdown_block.empty?
                code_block << swift_line
                markdown_block = ""
            end
        }
        results << markdown.render(markdown_block) if !markdown_block.empty?
        results << "\n{% highlight ruby %}" + code_block + "{% endhighlight %}\n" if !code_block.empty?

        subfolder = output_folder + "/" + subfolder_prefix + "/" + playground_page_title
        FileUtils.mkdir_p(subfolder) unless File.directory?(subfolder)
        File.open("#{subfolder}/index.html", 'w+') {|f| f.write(results) }
    end
    index << "</ol>"
end

File.open("#{output_folder}/index.html", 'w+') {|f| f.write(index) }
