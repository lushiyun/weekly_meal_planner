class WeeklyMealPlanner::CLI
  attr_accessor :diet_search_arr, :intolerance_search_arr, :query_search_arr, :search_hash

  #MAIN CONTROLLER
  def run
    puts "\nWelcome to the Weekly Meal Planner app!"
  
    get_diet_search
    get_intolerance_search
    get_query_search

    list_recipes
    select_recipe
    
  end 

  #SEARCH CONTROLLER
  def get_diet_search
    diet_results = WeeklyMealPlanner::FoodScraper.diets

    puts "\nPlease select your diet from the below list. If you have multiple choices, use comma to seperate them (e.g., '1, 3'). Press 'n' if you don't follow these diets."

    list_results(diet_results)

    diet_input_arr = gets.strip.split(", ")
    while !input_validation(diet_input_arr, diet_results) do
      puts "Invalid input. Let's try again."
      get_diet_search
    end

    @diet_search_arr = select_search_word(diet_input_arr, diet_results)
  end
  
  def get_intolerance_search
    intolerance_results = WeeklyMealPlanner::FoodScraper.intolerances

    puts "\nPlease select intolerances from the below list. If you have multiple choices, use comma to seperate them (e.g., '1, 3'). Press 'n' if you have none."

    list_results(intolerance_results)
    intolerance_input_arr = gets.strip.split(", ")
    while !input_validation(intolerance_input_arr, intolerance_results) do
      puts "Invalid input. Let's try again."
      get_intolerance_search
    end

    @intolerance_search_arr = select_search_word(intolerance_input_arr, intolerance_results)
  end

  def list_results(html_els)
    html_els.each.with_index(1) do |el, index|
      puts "#{index}. #{el}"
    end
  end

  def input_validation(input_arr, data)
    input_arr.all? do |input|
      (1..data.length).include?(input.to_i) || input.downcase == "n"
    end   
  end

  def select_search_word(input_arr, data)
    input_arr.map do |input|
      input.downcase == "n" ? "" : data[input.to_i - 1]
    end 
  end

  def get_query_search
    puts "\nWhat are you in the mood for? Please give me a keyword (e.g, 'soup', 'chicken', 'lunch')."

    query_input = gets.strip
    while !(/[a-z\s]+/ =~ query_input) do 
      puts "Invalid input. Let's try again."
      get_query_search
    end

    @query_search_arr = query_input.split(" ")
  end 

  def search_hash
    @search_hash = {
      diets: diet_search_arr,
      intolerances: intolerance_search_arr,
      queries: query_search_arr
    }
  end

  #RECIPE CONTROLLER
  def list_recipes
    puts "\nHere's your curated recipes."

    basic_recipes_arr = WeeklyMealPlanner::FoodAPI.get_recipes_list(search_hash)
    WeeklyMealPlanner::Recipe.create_from_collection(basic_recipes_arr)

    WeeklyMealPlanner::Recipe.all.each.with_index(1) do |recipe_obj, i|
      puts "#{i}. #{recipe_obj.title}"
    end 
  end

  def select_recipe 
    puts "\nSelect a recipe to read more;
          \nEnter 'new' to get new recipes for #{query_search_arr.join(" ")}; or
          \nEnter 'search' to search for other recipes."
    recipe_input = gets.strip.downcase

    while !selection_validation(recipe_input) do
      puts "Invalid input. Let's try again."
      select_recipe
    end

    if recipe_input == "new"
      list_recipes
      select_recipe
    elsif recipe_input == "search"
      get_query_search
      list_recipes
      select_recipe
    else 
      get_recipe(recipe_input)
    end 
  end

  def selection_validation(input)
    (1..10).include?(input.to_i) || input == "new" || input == "search"
  end

  def get_recipe(input)
    index = input.to_i - 1
    selected_recipe = WeeklyMealPlanner::Recipe.all[index]

    recipe_instruction = WeeklyMealPlanner::FoodAPI.get_recipe_instruction(selected_recipe.id).flatten
    selected_recipe.add_instruction(recipe_instruction)

    recipe_ingredients = WeeklyMealPlanner::FoodAPI.get_recipe_ingredients(selected_recipe.id)
    selected_recipe.add_ingredients(recipe_ingredients)

    display_recipe(selected_recipe)
  end 

  def display_recipe(recipe)
    puts "\nSteps:"
    recipe.instruction.each { |step| puts "#{step}" }
    puts "\nIngredients:"
    recipe.ingredients.each do |ingredient_hash|
      puts "#{ingredient_hash['amount']} #{ingredient_hash['unit']} #{ingredient_hash['name']}"
    end 
  end 

  #SHOPPING LIST CONTROLLER
  def add_ingredients
  end 

end