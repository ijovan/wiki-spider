class SearchHandler

  def self.find(start_node, end_node, channel)
    start_node = handle_encoding(start_node)
    end_node = handle_encoding(end_node)

    Reader.new(end_node, channel).find(start_node)
  end

  def self.find_by_url(start_url, end_url, channel)
    start_node = NameHandler.clean_url(start_url)
    end_node = NameHandler.clean_url(end_url)

    find(start_node, end_node, channel)
  end

  def self.handle_encoding(name)
    name.encode("utf-8")

    name.sub("%29", ")").sub("%28", "(")
  end

end
