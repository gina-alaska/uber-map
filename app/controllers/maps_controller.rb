class MapsController < ApplicationController
  before_filter :check_valid_site, :except => [:new, :create]
  
  def show
  end  
end
