# frozen_string_literal: true

module BxBlockDownloadoptions
  class DownloadOptionsController < ApplicationController

    def download_options
      render json: DownloadOptionsSerializer.new(current_user).serializable_hash, status: :ok
    end
  end
end 
