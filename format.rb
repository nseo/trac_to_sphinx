#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'find'
require 'fileutils'
require 'uri'

def header?(line)
  line =~ /^[-~`=^]+$/
end

def remove_trac_header(lines)
  last_modified_line = false
  start = false
  outputs = []
  lines.each do |line|
    if start
      outputs.push(line)
    else
      last_modified_line = true if line =~ /^`Last/
      if last_modified_line && line.strip.length == 0
        start = true
        outputs.push(":orphan:\n")
        outputs.push("\n")
      end
    end
  end
  outputs
end

def remove_trac_footer(lines)
  outputs = []
  lines.each do |line|
    outputs.push(line)
    break if line.strip == 'Download in other formats:'
  end
  outputs.push("\n") # put last break line to avoid warning
  outputs
end

def remove_attachments_section(lines)
  outputs = []
  in_section = false
  for i in 1..lines.size-1
    if ! in_section
      if lines[i-1].strip == "Attachments" && header?(lines[i])
        in_section = true
      else
        outputs.push(lines[i-1])
      end
    else
      if header?(lines[i])
        in_section = false
      end
    end
  end
  outputs
end

def put_anchor(lines, out_base)
  outputs = []
  for i in 1..lines.size-1
    if header?(lines[i])
      outputs.push(".. _#{out_base}##{lines[i-1].strip}:\n")
      outputs.push("\n")
    end
    outputs.push(lines[i-1])
  end
  outputs
end

def replace_internal_link(lines)
  outputs = []
  lines.each do |line|
    line =~ /`([^<]*)<\/trac\/nsp\/wiki([^#>]*)#([^>]*)>`_/
    text = $1
    link = $2
    anchor = $3
    line = line.gsub(/`([^<]*)<\/trac\/wiki([^#>]*)#([^>]*)>`_/, ":ref:`#{text}<#{link}##{anchor}>`")
    line = line.gsub(/`([^<]*)<\/trac\/wiki([^>]*)>`_/, ":doc:`\\1<\\2>`")
    outputs.push(line)
  end
  outputs
end

def replace_external_image(lines)
  outputs = []
  lines.each do |line|
    line = line.gsub(/`\|([^<]*)<([^>]*)>`_/, ".. image:: \\2")
    outputs.push(line)
  end
  outputs
end

def replace_image(lines)
  outputs = []
  lines.each do |line|
    if line =~ /`\|source:([^ ]*) *<\/trac\/browser([^>]*)>`_/
      path = $2
      line = line.gsub(/`\|source:([^ ]*) *<\/trac\/browser([^>]*)>`_/, ".. image:: /attachment#{path}")
    end
    line = line.gsub(/ *`([^ ]*) *<\/trac\/attachment([^>]*)>`_ */, ".. image:: /attachment\\2")
    outputs.push(line)
  end
  outputs
end

def replace_fig(lines)
  lines.map do |line|
    line.gsub(/^ *Fig/, "Fig")
  end
end

def replace_toc(lines)
  inside_toc = false
  outputs = [lines[0]]
  for i in 1..lines.size-1
    if ! inside_toc
      if lines[i-1].strip == "目次" && header?(lines[i])
        inside_toc = true 
      end
    else
      if header?(lines[i])
        outputs.pop # 目次
        outputs.push(".. contents:: 目次\n")
        outputs.push("  :local:\n")
        outputs.push("\n")
        outputs.push(lines[i-1])
        inside_toc = false
      end
    end
    if ! inside_toc
      outputs.push(lines[i])
    end
  end
  outputs
end

IN_PATH = '_cleanup'
OUT_PATH = '_format'

Find.find(IN_PATH) do |in_path|
  begin
    next if in_path !~ /^#{IN_PATH}\/(.*\.rst)$/
  rescue ArgumentError => e
    STDERR.puts in_path
    next
  end
  out_path = File.join(OUT_PATH, $1)
  puts out_path
  out_base = out_path.gsub(/\_format\/trac\/wiki(.*)\.rst/, "\\1")
  FileUtils.mkdir_p(File.dirname(out_path))
  out_file = File.open(out_path, "w")
  File.open(in_path, "r") do |file|
    lines = file.readlines
    lines = remove_trac_header(lines)
    lines = remove_trac_footer(lines)
    lines = replace_internal_link(lines)
    lines = replace_toc(lines)
    lines = put_anchor(lines, out_base)
    lines = replace_image(lines)
    lines = remove_attachments_section(lines)
    lines = replace_external_image(lines)
    lines = replace_fig(lines)
    out_file.write(lines.join(""))
  end
  out_file.close
end
