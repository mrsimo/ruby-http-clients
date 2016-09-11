class HomeController < ApplicationController
  def index
    if params[:delay]
      ms = params[:delay].to_i

      sleep ms / 1000.0
    end

    head :ok
  end
end
