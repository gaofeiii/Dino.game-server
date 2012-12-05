class ApplicationController < ActionController::Base
  after_filter :log_info if Rails.env.development?

  before_filter :redis_access_log

  private

  # === Logs ===

  def redis_access_log
    $redis_count = 0
  end

  def log_info
    logger.debug format("%-64s", '='*64)
    logger.debug format("| %-60s |", "* Redis access: #{$redis_count} times.")
    logger.debug format("| %-60s |", "* ")
    logger.debug format("| %-60s |", "*")
    logger.debug format("%-64s", '='*64)
    logger.debug "\n"
    # logger.debug '---- Response body ----'
    # logger.debug response.body 
  end

  # === Validation methods ===

  def validate_player
  	@player = Player[params[:player_id]]
    if @player.nil?
      render :json => {
        :message => Error.failed_message,
        :error_type => Error.types[:normal],
        :error => "PLAYER_NOT_FOUND"
      }
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

  def validate_dinosaur
    @dinosaur = Dinosaur[params[:dinosaur_id]]
    if @dinosaur.nil?
      render :json => {:error => "Invalid_dinosaur_id"} and return
    end
  end

  def validate_league
    @league = League[params[:league_id]]
    if @league.nil?
      render :json => {:error => "LEAGUE_NOT_FOUND"} and return
    end
  end

  def validate_building
    @building = Building[params[:building_id]]
    if @building.nil?
      render :json => {:error => Error.format_message("Building not exist")} and return
    end
  end

  def deny_access
    render :text => "Request denied."
  end

  
end
