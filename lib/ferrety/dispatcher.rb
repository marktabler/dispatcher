require "ferrety"
require "stock_ferret"
require "weather_ferret"
require "resque"
require 'JSON'
require 'httparty'
require 'active_support/core_ext/string'

ALERT_ENDPOINT = 'http://ferrety.net/alerts'
INTERNAL_PASSWORD = ENV['FERRETY_PASSWORD']

module Ferrety
  class Alert
    attr_accessor :body, :instruction_id

    def self.publish(params)
      alert = self.new(params)
      alert.submit
    end

    def initialize(params)
      @body = params[:body]
      @instruction_id = params[:instruction_id]
    end

    def submit
      #submit_debug
      options = { :body => { :alert => {:body => @body, :instruction_id => @instruction_id }, :pw => INTERNAL_PASSWORD} }
      HTTParty.post(ALERT_ENDPOINT, options)
    end

    def submit_debug
      puts "#{instruction_id}: #{body}"
    end
  end

  class Instruction
    @queue = :ferret_queue
    attr_accessor :id, :params

    def self.perform(json_data)
      self.new(json_data).perform
    end

    def initialize(json_data)
      data = JSON.parse(json_data)
      @id = data["id"]
      @params = data["params"]
      @ferret_type = data["ferret_type"]
    end

    def perform
      ferret.search.each do |alert_body|
        Alert.publish({body: alert_body, instruction_id: id})
      end
    end

    def ferret_class
      ("Ferrety::" + @ferret_type).classify.constantize
    end

    def ferret
      ferret_class.new(@params)
    end
  end
end