class WeeklyMealPlanner::Planner
  attr_accessor :name, :amount, :unit
  @@all = []

  def initialize(ingredients_hash)
    ingredients_hash.each {|k, v| self.send(("#{k}="), v)}
    @@all << self
  end

  def self.create_from_collection(ingredients_arr)
    ingredients_arr.each do |ingredients_hash|
      self.new(ingredients_hash)
    end
  end

end