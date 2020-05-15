class WeeklyMealPlanner::FoodScraper

  @@diets = []
  @@intolerances = []

  def self.diets
    if @@diets.empty?
      doc = get_doc("diets")
      doc.css('//section[@jss-title="Diets"]/h4').each {|el| @@diets << el.text}
    end
    @@diets
  end 

  def self.intolerances
    if @@intolerances.empty?
      doc = get_doc("intolerances")
      doc.css('//section[@jss-title="Intolerances"]/ul/li').each {|el| @@intolerances << el.text}
    end 
    @@intolerances
  end

  def self.get_doc(search_type)
    site = "https://spoonacular.com/food-api/docs##{search_type.capitalize}"
    Nokogiri::HTML(open(site))
  end 

end