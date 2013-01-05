class ApplicationController < ActionController::Base
  after_filter :log_info if Rails.env.development?

  before_filter :redis_access_log
  before_filter :set_default_locale
  before_filter :validate_sig

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

  def set_default_locale
    client_locale = request.env["HTTP_CLIENT_LOCALE"]
    I18n.locale = LocaleHelper.get_server_locale_name(client_locale)
  end

  def validate_sig
    cli_sig = request.env['HTTP_SIG']
    
    if request.env['HTTP_SIG'].nil?
      render :json => {:error => "INVALID_REQUEST"}, :status => 998 and return 
    end
    
    cdate = request.env['HTTP_DATE'].to_i
    sig  = request.env['HTTP_SIG'].to_s.downcase

    p "=== request.raw_post ===", request.raw_post
    p '=== request.url ===', request.fullpath
    p '=== date ===', cdate
    p "=== request.env['HTTP_SIG'] ===", cli_sig

    my_sig = case request.method
    when "GET"
      key_str = "#{request.fullpath}--#{cdate}--#{ServerInfo.cli_pri_key}"
      Digest::MD5.hexdigest(key_str)
    when "POST"
      key_str = "#{request.raw_post}--#{cdate}--#{ServerInfo.cli_pri_key}"
      Digest::MD5.hexdigest(key_str)
    else
      ""
    end
    p '=== MY_SIG ===', my_sig

    if my_sig != cli_sig
      render_error(Error.types[:normal], "INVALID_REQUEST") and return
    end

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
