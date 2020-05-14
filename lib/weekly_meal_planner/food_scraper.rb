class WeeklyMealPlanner::FoodScraper

  def self.diets
    site = "https://spoonacular.com/food-api/docs#Diets"
    doc = Nokogiri::HTML(open(site))
    doc.css('//section[@jss-title="Diets"]/h4').map {|el| el.text}
  end 
end