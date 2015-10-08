class SearchHandler

  def self.find(start_node, end_node, channel)
    start_node.encode("utf-8")
    end_node.encode("utf-8")

    Reader.new(end_node, channel).find(start_node)
  end

  def self.find_by_url(start_url, end_url, channel)
    start_node = NameHandler.clean_url(start_url)
    end_node = NameHandler.clean_url(end_url)

    find(start_node, end_node, channel)
  end

end
