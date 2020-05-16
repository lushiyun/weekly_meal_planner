class WeeklyMealPlanner::Recipe
  attr_accessor :id, :title
  attr_reader :instruction, :ingredients, :servings
  @@all = []

  def initialize(recipe_hash)
    recipe_hash.each {|k, v| self.send(("#{k}="), v)}
    @@all << self
  end

  def self.create_from_collection(recipes_arr)
    recipes_arr.each do |recipe_hash|
      self.new(recipe_hash)
    end
  end

  def add_instruction(instruction)
    @instruction = instruction
  end

  def add_ingredients(ingredients)
    @ingredients = ingredients
  end

  def add_servings(servings)
    @servings = servings
  end 

  def self.all
    @@all
  end

  def self.reset
    @@all.clear
  end 

end 