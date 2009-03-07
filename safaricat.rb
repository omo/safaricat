#!/usr/bin/ruby -rubygems

require 'hpricot'
require 'erb'

module Hpricot
  class Elem

    attr_accessor :serial_number
    @@last_serial = 0

    alias old_initialize initialize
    def initialize(stag, children=nil, etag=nil)
      old_initialize(stag, children, etag)
      @@last_serial = number(@@last_serial.succ)
    end

    def number(n)
      self.serial_number = n
      if children
        children.each do |c|
          n = c.number(n.succ) if c.kind_of?(Elem)
        end
      end
      n
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
    .st1 { display: none; }
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
#    doc.search("//h1|//h2|//h3|//h4|//h5|" +
#               "//[@class='docText']|" +
#               "//[@class='st1']")
    doc.at("//[@id='SectionContent_Div']").children
  end

  def self.fill_images(texts)
    texts.map do |t|
      if (t["class"] == "docFigureTitle" ||
          t["class"] == "st1")
        i = t
        i = i.next_sibling until nil == i or i.name == "img"
        i ? [t, i] : t
      else
        t
      end
    end.flatten
  end

  def self.rewrite(fn, t, depth=0)
    if Hpricot::Elem == t.class 
      if t.name == "img"
        t["src"] = File.join(File.dirname(fn), t["src"]) 
      end
      t.children.each {|c| rewrite(fn,c, depth+1) }
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
  texts = texts.map { |t| Bulk.rewrite(fn, t) }
  texts = texts.sort{ |a,b| a.serial_number <=> b.serial_number }
  bulk.sections << Section.new(texts)
end

print bulk.to_html
