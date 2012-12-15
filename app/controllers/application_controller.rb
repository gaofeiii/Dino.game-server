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

  # Render error message.
  def render_error(error_type = nil, error_message = nil)
    render :json => {
      :message => Error.failed_message,
      :error_type => error_type.to_i,
      :error => Error.format_message(error_message)
    }
  end

  def render_success(data = {})
    render :json => {:message => Error.success_message}.merge!(data)
  end

  # === Validation methods ===

  def validate_player
  	@player = Player[params[:player_id]]
    if @player.nil?
      render_error(Error.types[:normal], "Invalid player id") and return
    end
  end

  def validate_village
    @village = Village[params[:village_id]]
    if @village.nil?
      render_error(Error.types[:normal], "Invalid village id") and return
    end
  end

  def validate_item
    @item = Item[params[:item_id]]
    if @item.nil?
      render_error(Error.types[:normal], "Invalid item id") and return
    end
  end

  def validate_dinosaur
    @dinosaur = Dinosaur[params[:dinosaur_id]]
    if @dinosaur.nil?
      render_error(Error.types[:normal], "Invalid dinosaur id") and return
    end
  end

  def validate_league
    @league = League[params[:league_id]]
    if @league.nil?
      render_error(Error.types[:normal], "Invalid league id") and return
    end
  end

  def validate_building
    @building = Building[params[:building_id]]
    if @building.nil?
      rrender_error(Error.types[:normal], "Invalid building id") and return
    end
  end

  def deny_access
    render :text => "Request denied."
  end

  
end
