class Node

  attr_reader :name

  def initialize(name)
    @name = name
    @successors = []
  end

  def [](index)
    @successors[index]
  end

  def add_edge(successor)
    @successors << successor
  end

  def to_s
    "#{@name} -> [#{@successors.map(&:name).join(' ')}]"
  end

  def edges
    @successors
  end

  def length
    @successors.length
  end

end