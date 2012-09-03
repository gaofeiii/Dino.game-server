class ApplicationController < ActionController::Base
  after_filter :log_info if Rails.env.development?

  before_filter :redis_access_log

  private

  def redis_access_log
    $redis_count = 0
  end

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
    logger.debug format("%-64s", '='*64)
    logger.debug format("| %-60s |", "* Redis access: #{$redis_count} times.")
    logger.debug format("| %-60s |", "*")
    logger.debug format("| %-60s |", "*")
    logger.debug format("%-64s", '='*64)
  end
end
