class ApplicationController < ActionController::Base
  after_filter :log_info if Rails.env.development?

  before_filter :check_server_status
  before_filter :check_version

  before_filter :redis_access_log
  before_filter :set_default_locale
  # before_filter :validate_sig
  # before_filter :validate_session

  private

  def check_server_status
    status = Ohm.redis.get("Server:status")

    if status.nil?
      render :json => {
        :message => I18n.t('system_maintaining'),
        :error_type => Error::NORMAL,
        :error => I18n.t('system_maintaining')
      }
    end
  end

  def check_version
    p "======= Client Version #{request.env['HTTP_USER_AGENT']}"
    
    # return true if Rails.env.development?

    if not request.env['HTTP_USER_AGENT'].in?(['1.1', '1.1.1'])
      render :json => {
        :message => I18n.t('client_version_expired'),
        :error_type => Error::NORMAL,
        :error => I18n.t('client_version_expired')
      }
    end
    # if Ohm.redis.exists('Server:check_version')
    # end
  end

  def redis_access_log
    $redis_count = 0
  end

  def log_info
    logger.debug format("%-64s", '='*64)
    logger.debug format("| %-60s |", "* Redis access: #{$redis_count} times.")
    logger.debug format("| %-60s |", "* Client locale: #{request.env['HTTP_CLIENT_LOCALE']}")
    logger.debug format("| %-60s |", "*")
    logger.debug format("%-64s", '='*64)
    logger.debug "\n"
    # logger.debug '---- Response body ----'
  end

  def validate_session
    client_session_key = request.env['HTTP_GAME_SESSION']
    p "--- client_session_key: #{client_session_key} ---"

    if client_session_key.blank? || !Session.has_player_id?(client_session_key)
      render_error(Error::NORMAL, "One account, one login") and return
    end
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

    # p "=== request.raw_post ===", request.raw_post
    # p '=== request.url ===', request.fullpath
    # p '=== date ===', cdate
    # p "=== request.env['HTTP_SIG'] ===", cli_sig

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

    if my_sig != cli_sig
      render_error(Error::NORMAL, "INVALID_REQUEST") and return
    end

  end

  # Render error message.
  def render_error(error_type = nil, error_message = nil)
    render :json => {
      # :message => Error.failed_message,
      :message => error_message,
      :error_type => error_type.to_i,
      :error => error_message
    }
  end

  def render_success(data = nil)
    if data.is_a?(Hash)
      render :json => {:message => Error.success_message}.merge!(data)
    elsif data.is_a?(String)
      render :json => {:message => Error.success_message, :result => data}
    else
      render :json => {:message => Error.success_message}
    end
  end

  # === Validation methods ===

  def validate_player
  	@player = Player[params[:player_id]]
    if @player.nil?
      render_error(Error::NORMAL, "Invalid player id") and return
    end
  end

  def validate_village
    @village = Village[params[:village_id]]
    if @village.nil?
      render_error(Error::NORMAL, "Invalid village id") and return
    end
  end

  def validate_item
    @item = Item[params[:item_id]]
    if @item.nil?
      render_error(Error::NORMAL, "Invalid item id") and return
    end
  end

  def validate_dinosaur
    @dinosaur = Dinosaur[params[:dinosaur_id]]
    if @dinosaur.nil?
      render_error(Error::NORMAL, "Invalid dinosaur id") and return
    end
  end

  def validate_league
    @league = League[params[:league_id]]
    if @league.nil?
      render_error(Error::NORMAL, "Invalid league id") and return
    end
  end

  def validate_building
    @building = Building[params[:building_id]]
    if @building.nil?
      render_error(Error::NORMAL, "Invalid building id") and return
    end
  end

  def deny_access
    render :text => "Request denied."
  end

  
end
