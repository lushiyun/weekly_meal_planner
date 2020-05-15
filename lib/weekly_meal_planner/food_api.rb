class WeeklyMealPlanner::FoodAPI
  AUTH_KEY = "b1c4405a65e94d16a5faf6f9dc9ca1a4"

  def self.get_recipes(search)
    parsed_params = parse_search(search)

    url = "https://api.spoonacular.com/recipes/search?offset=#{parsed_params[:offset]}&number=#{parsed_params[:number]}&query=#{parsed_params[:queries]}&diet=#{parsed_params[:diets]}&intolerances=#{parsed_params[:intolerances]}&apiKey=#{AUTH_KEY}"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end

  def self.parse_search(search_hash)
    search_hash.transform_values! { |input_arr| input_arr.join("&").downcase.gsub(" ", "") }
    search_hash[:number] = "10"
    search_hash[:offset] = rand(200).to_s
    search_hash
  end 

end




