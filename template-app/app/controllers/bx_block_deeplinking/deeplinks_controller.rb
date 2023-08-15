module BxBlockDeeplinking
  class DeeplinksController < ActionController::Base
    def deeplink
    	# This is deeplink
      @data = params[:id] 
    end
  end
end