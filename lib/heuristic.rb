class Heuristic

  def initialize(target, target_words)
    @target = target
    @target_words = target_words
    @to_visit = {}
    @visited = []
  end

  def link_val(link)
    compare_target(link) + compare_words(link)
  end

  def compare_target(link)
    score = 0

    parts = @target.split("_")

    parts.each { |part| score += 10 if link.eql?(part) }

    score
  end

  def compare_words(link)
    score = 0

    @target_words.each do |word|
      if link.eql? word
        score += 5
      else
        parts = word.split("_")

        parts.each { |part| score += 1 if link.eql?(part) }
      end
    end

    score
  end

  def rate_score(links)
    links.each do |key, value|
      value[:score] = link_val(key)
      links[key] = value
    end
  end

  def new_scores(links)
    rate_score(links).each do |key, value|
      unless @visited.include?(key)
        if @to_visit.has_key?(key)
          update_score(key, value)
        else
          @to_visit[key] = value
        end
      end
    end
  end

  def update_score(key, value)
    @to_visit[key][:score] += value[:score]

    if value[:path].count < @to_visit[key][:path].count
      @to_visit[key][:path] = value[:path]
    end
  end

  def current_best
    @to_visit.max_by { |k,v| v[:score] }
  end

  def mark_visited(link)
    @visited.push(link)
    @to_visit.delete(link)
  end

end
