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
  end

  private

  def unpack(file, parent)
    links = {}

    file.css(@selector).each do |a|
      link = a["href"]

      next unless link.include?("/wiki/")

      name = link.split("/wiki/")[1]

      if name.eql?(@target)
        return { :final_path => parent.clone.push(@target) }
      end

      next if ((skip_list.include?(name) &&
          @selector.include?("li")) ||
          a["rel"].eql?("nofollow") ||
          name.include?(":") ||
          link.split("/wiki/")[0] != "")

      cleaned = name.split("#")[0]

      links[cleaned] = { :path => parent.clone.push(cleaned) }
    end

    links
  end

  def skip_list
    [
      "International_Standard_Book_Number",
      "International_Standard_Serial_Number",
      "Digital_object_identifier",
      "Integrated_Authority_File",
      "Virtual_International_Authority_File",
      "Geographic_coordinate_system",
      "National_Diet_Library",
      "Oxford_University_Press",
      "Google_Books",
      "Library_of_Congress_Control_Number",
      "OCLC"
    ]
  end

end
