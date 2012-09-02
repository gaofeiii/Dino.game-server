class ApplicationController < ActionController::Base
  after_filter :log_info if Rails.env.development?

  private

  def validate_player
  	@player = Player[params[:player_id]]
    if @player.nil?
      render :json => {:error => "PLAYER_NOT_FOUND"} and return
    end
  end

  def validate_village
    @village = Village[params[:village_id]]
    if @village.nil?
      render :json => {:error => "VILLAGE_NOT_FOUND"} and return
    end
  end

  def validate_item
    @item = Item[params[:item_id]]
    if @item.nil?
      render :json => {:error => "ITEM_NOT_FOUND"} and return
    end
  end

  def log_info
  	# pp "=== Response ===", JSON.parse(response.body).deep_symbolize_keys
    pp "=== Response ===", response.body
  end
end
