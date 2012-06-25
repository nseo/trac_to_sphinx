#!/usr/bin/env ruby
require 'find'

IN_PATH = '_source'
OUT_PATH = '_convert'

Find.find(IN_PATH) do |in_path|
  begin
    next if in_path !~ /^#{IN_PATH}\/(.*)\.html?$/
  rescue ArgumentError => e
    STDERR.puts in_path
    next
  end
  out_path = File.join(OUT_PATH, $1 + ".rst")
  puts "sudo /usr/local/bin/pandoc -f html -t rst -o #{out_path} #{in_path}"
  %x(mkdir -p #{File.join(OUT_PATH, File.dirname($1))})
  %x(sudo /usr/local/bin/pandoc -f html -t rst -o #{out_path} #{in_path})
end

