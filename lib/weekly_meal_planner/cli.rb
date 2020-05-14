class WeeklyMealPlanner::CLI

  attr_accessor :diet_input_arr

  def run
    puts "\nWelcome to the Weekly Meal Planner app!"
    puts "I will help you plan your meals for the upcoming week and generate your shopping list."

    get_diet_input
    
  end 

  def get_diet_input
    puts "\nPlease select your diet from the below list. If you have multiple choices, use comma to seperate them (e.g., '1, 3'). Press 'n' if you don't follow these diets. Press enter to confirm your selection."
    list_results(WeeklyMealPlanner::FoodScraper.diets)
    @diet_input_arr = gets.strip.split(", ")
    if !input_validation(@diet_input_arr, WeeklyMealPlanner::FoodScraper.diets)
      self.get_diet_input
    end 
  end 

  def list_results(html_elms)
    html_elms.each.with_index(1) do |elm, index|
      puts "#{index}. #{elm}"
    end
  end 

  def input_validation(input_arr, data)
    input_arr.each do |input|
      (1..data.length).include?input.to_i || input.downcase == "n"
    end 
    
  end 

end