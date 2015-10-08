require 'nokogiri'

class CSSUnpacker

  def initialize(target, selector, tar)
    @target = target
    @selector = selector
    @tar = tar
  end

  def unpack(file, parent)
    links = {}

    file.css(@selector).each do |a|
      link = a["href"]

      if link.sub("/wiki/", "").eql?(@target) && !@tar
        return { :final_path => parent.clone.push(@target) }
      end

      next if ((link.include?("International_Standard_Book_Number") &&
          @selector.include?("li")) ||
          a["rel"].eql?("nofollow") ||
          link.include?(":"))

      if link.include?("/wiki/")
        l = link.sub("/wiki/", "")

        l.sub!(l[/#.*/], "") if l.include?("#")

        links[l] = { :path => parent.clone.push(l) }
      end
    end

    links
  end

  def acquire_links(link, path)
    file = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/#{link}"))

    unpack(file, path)
  rescue
    puts "ERROR: #{link}"
  end

end
