require 'open-uri'
require 'net/http'
require 'json'
require 'pry'

class WeeklyMealPlanner::FoodAPI
  AUTH_KEY = "b1c4405a65e94d16a5faf6f9dc9ca1a4"

  def self.get_recipes(search_params)
    url = "https://api.spoonacular.com/recipes/search?query=#{search_params[:query]}&cuisine=#{search_params[:cuisine]}&diet=#{search_params[:diet]}&intolerances=#{search_params[:intolerances]}&apiKey=#{auth_key}"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end

end 



