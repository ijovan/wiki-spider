require 'nokogiri'
require 'open-uri'

class CSSUnpacker

  def initialize(target, selector)
    @target = target
    @selector = selector
  end

  def acquire_links(node)
    file = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/#{node[0]}"))

    unpack(file, node[1][:path])
  rescue
    puts "ERROR: #{node}"
  end

  private

  def unpack(file, parent)
    links = {}

    file.css(@selector).each do |a|
      link = a["href"]

      if link.sub("/wiki/", "").eql?(@target)
        return { :final_path => parent.clone.push(@target) }
      end

      next if ((link.include?("International_Standard_Book_Number") &&
          @selector.include?("li")) ||
          a["rel"].eql?("nofollow") ||
          link.include?(":"))

      if link.include?("/wiki/")
        cleaned = link.sub("/wiki/", "").split("#")[0]

        links[cleaned] = { :path => parent.clone.push(cleaned) }
      end
    end

    links
  end

end
