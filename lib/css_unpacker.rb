require 'nokogiri'
require 'open-uri'
require 'uri'

class CSSUnpacker

  def initialize(target, selector)
    @target = target
    @selector = selector
  end

  def acquire_links(node)
    article_name = URI.escape(node[0])

    file = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/#{article_name}"))

    unpack(clean_up_refs(file), node[1][:path])
  end

  private

  def clean_up_refs(file)
    file.search(".reflist").each do |node|
      node.remove
    end

    file
  end

  def unpack(file, parent)
    links = {}

    file.css(@selector).each do |a|
      link = a["href"]

      next unless link.include?("/wiki/")

      name = link.split("/wiki/")[1].split("#")[0]

      name = URI.unescape(name)

      if name.eql?(@target)
        return { :final_path => parent.clone.push(@target) }
      end

      next if ((skip_list.include?(name) &&
          @selector.include?("li")) ||
          a["rel"].eql?("nofollow") ||
          name.include?(":") ||
          link.split("/wiki/")[0] != "")

      links[name] = { :path => parent.clone.push(name) }
    end

    links
  end

  def skip_list
    [
      "International_Standard_Book_Number",
      "International_Standard_Serial_Number",
      "International_Standard_Name_Identifier",
      "Virtual_International_Authority_File",
      "Digital_object_identifier",
      "Integrated_Authority_File",
      "Virtual_International_Authority_File",
      "Geographic_coordinate_system",
      "National_Diet_Library",
      "Oxford_University_Press",
      "Google_Books",
      "Library_of_Congress_Control_Number",
      "OCLC",
      "LIBRIS",
      "HarperCollins",
      "Macmillan_Publishers",
      "Penguin_Books",
      "Cambridge_University_Press",
      "Yale_University_Press",
      "British_Library",
      "YouTube"
    ]
  end

end
