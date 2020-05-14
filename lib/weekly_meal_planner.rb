require_relative "./weekly_meal_planner/version"
require_relative "./weekly_meal_planner/cli"
require_relative "./weekly_meal_planner/food_scraper"
# require "weekly_meal_planner/food_api"
# require "weekly_meal_planner/planner"
# require "weekly_meal_planner/search"

require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'json'
require 'pry'

module WeeklyMealPlanner
  class Error < StandardError; end
  # Your code goes here...
end
