#!/usr/bin/ruby -rubygems

require 'hpricot'
require 'erb'

module Hpricot
  class Elem

    attr_reader :serial_number
    @@last_serial = 0

    alias old_initialize initialize
    def initialize(stag, children=nil, etag=nil)
      old_initialize(stag, children, etag)
      @@last_serial = @serial_number = @@last_serial.succ
    end
  end
end

BULK_HTML_TEMPLATE = <<EOF
<html>
  <head>
  <style type="text/css">
    body { font-family: verdana, sans-serif; font-weight: normal; color: #000; font-size: medium; margin: 0.5em; }
    div.codeSegmentsExpansionLinks { display: none; }
    .docTextHighlight  {font-weight: bold; }
    .docText, .docListfi {font-family: verdana, sans-serif; color: black; }
    pre {color: #000066; font-family: 'Courier New', Courier, monospace; }
    .docEmphasis {font-style: italic; }
    /* .safari-section { page-break-after: always; } */
    .docChapterTitle, .docPartTitle { page-break-before: always; }
  </style>
  <title><%= title %></html>
  </head>
  <body>
  <h1><%= title %></h1>
  <% sections.each do |sec| %>
  <%=  sec.to_html %>
  <% end %>
  </body>
</html>
EOF

SECTION_HTML_TEMPLATE = <<EOF
<div class="safari-section">
<%= texts.map {|i| i.to_s }.join %>
</div>
EOF

class Bulk
  
  attr_reader :sections
  attr_accessor :title

  def initialize
    @sections = []
  end

  def to_html
    ERB.new(BULK_HTML_TEMPLATE).result(binding)
  end

  def self.find_texts(doc)
    doc.search("//h1|//h2|//h3|//h4|//h5|" +
               "//[@class='docText']")
  end

  def self.fill_images(texts)
    texts.map do |t|
      if t["class"] == "docFigureTitle"
        i = t
        i = i.next_sibling until nil == i or i.name == "img"
        i ? [t, i] : t
      else
        t
      end
    end.flatten
  end

  def self.rewrite_image_path(fn, t)
    if Hpricot::Elem == t.class 
      if t.name == "img"
        t["src"] = File.join(File.dirname(fn), t["src"]) 
      else
        t.children.each {|c| rewrite_image_path(fn,c) }
      end
    end
    t
  end

end

class Section < Struct.new(:texts)
  def to_html
    ERB.new(SECTION_HTML_TEMPLATE).result(binding)
  end
end


filenames = ARGV
bulk = Bulk.new


filenames.each do |fn|
  doc = Hpricot(open(fn))
  bulk.title ||= doc.search("//title").first.inner_html
  texts = Bulk.fill_images(Bulk.find_texts(doc))
  texts = texts.map { |t| Bulk.rewrite_image_path(fn, t) }
  texts = texts.sort{ |a,b| a.serial_number <=> b.serial_number }
  bulk.sections << Section.new(texts)
end

print bulk.to_html
