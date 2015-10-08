class ScoreHandler

  def initialize(target, target_words)
    @heuristic = Heuristic.new(target, target_words)
    @to_visit = {}
    @visited = []
  end

  def take_current_best
    max = @to_visit.max_by { |k, v| v[:score] }

    mark_visited(max[0])

    max
  end

  def new_scores(links)
    @visited.each { |key| links.delete(key) }

    rate_score(links).each do |key, value|
      if @to_visit.has_key?(key)
        update_score(key, value)
      else
        @to_visit[key] = value
      end
    end
  end

  private

  def rate_score(links)
    links.each do |key, value|
      value[:score] = @heuristic.link_val(key)
      links[key] = value
    end
  end

  def update_score(key, value)
    @to_visit[key][:score] += value[:score]

    if value[:path].count < @to_visit[key][:path].count
      @to_visit[key][:path] = value[:path]
    end
  end

  def mark_visited(link)
    @visited.push(link)
    @to_visit.delete(link)
  end

end
