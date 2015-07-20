class StaticpagesController < ApplicationController
  def index
  	@user = User.new
  end

  def help
  end
end
