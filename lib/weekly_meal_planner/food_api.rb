class WeeklyMealPlanner::FoodAPI
  AUTH_KEY = "b1c4405a65e94d16a5faf6f9dc9ca1a4"

  def self.get_recipes_list(search)
    parsed_params = parse_search(search)

    url = "https://api.spoonacular.com/recipes/search?offset=#{parsed_params[:offset]}&number=#{parsed_params[:number]}&query=#{parsed_params[:queries]}&diet=#{parsed_params[:diets]}&intolerances=#{parsed_params[:intolerances]}&instructionsRequired=true&apiKey=#{AUTH_KEY}"

    get_JSON(url)["results"].map do |recipe_hash|
      recipe_hash.select { |k, v| k == "id" || k == "title" }
    end 
  end

  def self.parse_search(search_hash)
    search_hash.transform_values! { |input_arr| input_arr.join("&").downcase.gsub(" ", "") }
    search_hash[:number] = "10"
    search_hash[:offset] = rand(200).to_s
    search_hash
  end

  def self.get_recipe_instruction(id)
    url = "https://api.spoonacular.com/recipes/#{id}/analyzedInstructions?apiKey=#{AUTH_KEY}"

    binding.pry

    if get_JSON(url)[0]
      get_JSON(url)[0]["steps"].map do |step_hash|
        step_hash.values_at("step")
      end
    end
  end 

  def self.get_recipe_ingredients(id)
    url = "https://api.spoonacular.com/recipes/#{id}/information?includeNutrition=false&apiKey=#{AUTH_KEY}"

    if get_JSON(url)["extendedIngredients"]
     ingredient_list = get_JSON(url)["extendedIngredients"].map do |ingredient_hash|
        ingredient_hash.select { |k, v| k == "name" || k == "amount" || k == "unit"}
      end 
    end

    if get_JSON(url)["servings"]
      ingredient_list get_JSON(url)["servings"]


  end
  
  def self.get_JSON(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end 

end