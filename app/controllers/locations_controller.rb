class LocationsController < ApplicationController
  before_filter :find_location
  before_filter :set_body_classes

  def index
  end

  def show
    @body_classes << 'two_column'
    @facility_data = @location.find_facilities
  end

  def factoid
    @body_classes << 'two_column'
    @factoid = Factoid.find(params[:id])
    @result = @factoid.execute(@location)
    
    variables = []
    @result.search("head variable").map{|var| var["name"]}.each_slice(2) do |slice|
      variables << slice
    end
    @headings = variables.map{|v|v[0]}
    
    
    @data = [] #The list of data as received in the query, not organized by company name
    #render :xml => @result
    #return    
    @result.search("result").each do |r|
      row = {}
      	variables.each do |lit_var, uri_var|
	        row[lit_var.to_sym] = [
	        						r.search("binding[name=#{lit_var}] literal").first.content, 
	        						r.search("binding[name=#{uri_var}] uri").first.content
        						]
	    end
	    @data << row
    end
  end

  def search
    @location = Location.new(params[:q])
    redirect_to location_path(@location)
    rescue Graticule::Error
      raise ActiveRecord::RecordNotFound
  end

  protected

  def find_location
    @location = Location.new("#{params[:city]}, #{params[:state]}") if params[:city] and params[:state]
  end

  def set_body_classes
    @body_classes = []
  end

end