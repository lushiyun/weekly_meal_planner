class WeeklyMealPlanner::CLI
  attr_accessor :diet_search_arr, :intolerance_search_arr, :query_search_arr, :search_hash

  #MAIN CONTROLLER
  def run
    puts "\nWelcome to the Weekly Meal Planner app!"
  
    get_diet_search
    get_intolerance_search
    get_query_search

    list_recipes

    recipe_selection
    
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

    @diet_search_arr = diet_input_arr.map do |input|
      if input.downcase == "n"
        ""
      else 
        index = input.to_i - 1
        diet_results[index]
      end 
    end
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

    @intolerance_search_arr = intolerance_input_arr.map do |input|
      if input.downcase == "n"
        ""
      else 
        index = input.to_i - 1
        intolerance_results[index]
      end 
    end
  end

  def list_results(html_elms)
    html_elms.each.with_index(1) do |elm, index|
      puts "#{index}. #{elm}"
    end
  end

  def input_validation(input_arr, data)
    input_arr.all? do |input|
      (1..data.length).include?(input.to_i) || input.downcase == "n"
    end   
  end

  def get_query_search
    puts "\nWhat are you in the mood for? Please give me a keyword (e.g, 'soup', 'salmon')."

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
    recipes = WeeklyMealPlanner::FoodAPI.get_recipes(search_hash)
    recipes.each.with_index(1) do |recipe, index|
      puts "#{index}. #{recipe['title']}"
    end
  end

  def recipe_selection 
    puts "\nSelect a recipe to read more;
          \nEnter 'new' to get new recipes for #{query_search_arr.join(" ")}; or
          \nEnter 'search' to search for other recipes."
    recipe_input = gets.strip.downcase

    while !selection_validation(recipe_input) do
      puts "Invalid input. Let's try again."
      recipe_selection
    end

    if recipe_input == "new"
      list_recipes
      recipe_selection
    elsif recipe_input == "search"
      get_query_search
      list_recipes
      recipe_selection
    else 
      get_recipe(input)
    end 
  end

  def selection_validation(input)
    (1..10).include?(input.to_i) || input == "new" || input == "search"
  end

  def get_recipe(input)
    
  end 

end