class WeeklyMealPlanner::CLI
  attr_accessor :diet_search_arr, :intolerance_search_arr, :query_search_arr, :search_hash

  ####MAIN CONTROLLER###
  def run
    puts "\nWelcome to the Weekly Meal Planner app!"
  
    get_diet_search
    get_intolerance_search
    get_query_search

    get_recipes_list
    display_recipes_list
    select_recipe
  end 

  ####SEARCH CONTROLLER###
  def get_diet_search
    diet_results = WeeklyMealPlanner::FoodScraper.diets

    puts "\nPlease select your diet from the below list. If you have multiple choices, use comma to seperate them (e.g., '1, 3'). Press 'n' if you don't follow these diets."

    list_results(diet_results)

    diet_input_arr = gets.strip.split(", ")
    unless input_validation(diet_input_arr, diet_results)
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
    unless input_validation(intolerance_input_arr, intolerance_results)
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

  #Get keyword from user for API search query; no scraping needed
  def get_query_search
    puts "\nWhat are you in the mood for? Please give me a keyword (e.g, 'soup', 'chicken', 'lunch')."

    query_input = gets.strip.downcase
    unless (/[a-z\s]+/ =~ query_input)
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

  #####RECIPE CONTROLLER####
  def get_recipes_list
    puts "\nHere's your curated recipes."
    #Get a list of 10 randomly selected recipes based on diets, intolerances and keywords; only pull recipe ID and title from API
    basic_recipes_arr = WeeklyMealPlanner::FoodAPI.get_recipes_list(search_hash)
    WeeklyMealPlanner::Recipe.create_from_collection(basic_recipes_arr)
  end 

  def display_recipes_list
    if WeeklyMealPlanner::Recipe.all.empty?
      empty_return
    else
      WeeklyMealPlanner::Recipe.all.each.with_index(1) do |recipe_obj, i|
        puts "#{i}. #{recipe_obj.title}"
      end 
    end 
  end

  def empty_return
    puts "No information found."
  end 

  #Make a combined method to be used when user chooses new search or new list
  def make_new_recipes_list
    WeeklyMealPlanner::Recipe.reset
    get_recipes_list
    display_recipes_list
  end 

  def select_recipe 
    puts "\nSelect a recipe to read more;\nEnter 'new' to get new recipes for #{query_search_arr.join(" ")}; or\nEnter 'search' to search for other recipes."
    recipe_input = gets.strip.downcase

    unless selection_validation(recipe_input)
      puts "Invalid input. Let's try again."
      select_recipe
    end

    if recipe_input == "search"
      get_query_search
      make_new_recipes_list
      select_recipe
    elsif recipe_input == "new"
      make_new_recipes_list
      select_recipe
    else 
      get_recipe(recipe_input)
    end 
  end

  def selection_validation(input)
    (1..WeeklyMealPlanner::Recipe.all.length).include?(input.to_i) || input == "new" || input == "search"
  end

  def get_recipe(input)
    index = input.to_i - 1
    selected_recipe = WeeklyMealPlanner::Recipe.all[index]
    add_recipe_details(selected_recipe)
  end 

  def add_recipe_details(recipe)
    recipe_instruction = WeeklyMealPlanner::FoodAPI.get_recipe_instruction(recipe.id)
    if recipe_instruction
      recipe.add_instruction(recipe_instruction.flatten)
    end

    recipe_ingredients = WeeklyMealPlanner::FoodAPI.get_recipe_ingredients(recipe.id)
    if recipe_ingredients
      recipe.add_ingredients(recipe_ingredients)
    end 

    recipe_servings = WeeklyMealPlanner::FoodAPI.get_servings(recipe.id)
    recipe.add_servings(recipe_servings)

    display_recipe(recipe)
  end 

  def display_recipe(recipe)
    puts "\nSteps:"
    recipe.instruction.each { |step| puts "#{step}" }
    puts "\nIngredients:"
    recipe.ingredients.each do |ingredient_hash|
      parsed_amount = parse_ingredient_amount(ingredient_hash["amount"])
      puts "#{parsed_amount} #{ingredient_hash['unit']} #{ingredient_hash['name']}"
    end
    puts "\nServings: #{recipe.servings}"
    
    planner_selection(recipe)
  end

  #11.0 -> 11; 0.25 -> 1/4; 1.47472 -> 1 1/2
  def parse_ingredient_amount(amount)
    amount_arr = amount.to_s.split(".")
    if amount_arr[1] == "0"
      amount_arr[0]
    else
      amount = amount.to_r.rationalize(0.05)
      amount_as_integer = amount.to_i
      if (amount_as_integer != amount.to_f) && (amount_as_integer > 0)
        fraction = amount - amount_as_integer
        "#{amount_as_integer} #{fraction}"
      else
        amount.to_s
      end
    end
  end

  ####PLANNER CONTROLLER####
  def planner_selection(recipe)
    puts "\nWould you like to add ingredients to your planner? (y/n)"
    planner_input = gets.strip.downcase
    unless planner_input_validation(planner_input)
      puts "Invalid input. Let's try again."
      planner_selection(recipe)
    end

    if planner_input == "y"
      update_servings(recipe)
      display_planner
    else 
      display_recipes_list
      select_recipe
    end
  end 

  def update_servings(recipe)
    puts "\nHow many servings of #{recipe.title} would you like to make?"
    servings_input = gets.strip.to_i
    unless servings_input > 0
      puts "Invalid input. Let's try again."
      update_servings(recipe)
    end 
    
    updated_ingredients = recipe.ingredients.map do |ingredient_hash|
      ingredient_hash["amount"] *= (servings_input.to_f / recipe.servings.to_f)
      ingredient_hash
    end

    WeeklyMealPlanner::Planner.create_from_collection(updated_ingredients)
    puts "\nIngredients for #{servings_input} servings of #{recipe.title} added to your planner."
  end 

  def display_planner
    puts "\nWould you like to see your planner? (y/n)"
    display_planner_input = gets.strip.downcase
    unless planner_input_validation(display_planner_input)
      puts "Invalid input. Let's try again."
      display_planner
    end

    if display_planner_input == "y"
      WeeklyMealPlanner::Planner.all.each do |ingredient_obj|
        parsed_amount = parse_ingredient_amount(ingredient_obj.amount)
        puts "#{parsed_amount} #{ingredient_obj.unit} #{ingredient_obj.name}"
      end
      get_more_input
    else 
      display_recipes_list
      select_recipe
    end
  end 

  def planner_input_validation(input)
    input == "y" || input == "n"
  end 

  def get_more_input
    puts "\nEnter 'more' to add more ingredients or 'exit' to quit."
    planner_more_input = gets.strip.downcase
    unless more_input_validation(planner_more_input)
      puts "\nInvalid input. Let's stry again."
      get_more_input
    end 

    if planner_more_input == "more"
      display_recipes_list
      select_recipe
    else 
      puts "\nGoodbye!"
    end  
  end

  def more_input_validation(input)
    input == "more" || input == "exit"
  end
end