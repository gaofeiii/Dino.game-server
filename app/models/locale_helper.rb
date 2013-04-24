class LocaleHelper

	@@locale_namespace = {
		'cn' => :cn,
		'zh' => :cn,
		'zh-Hans' => :cn,
		'zh_CN' => :cn,
		'en' => :en
	}

	class << self

		def get_server_locale_name(ori_name)
			name = @@locale_namespace[ori_name.to_s]
			if name.nil?
				name = ServerInfo.default_locale
			end
			return name
		end

	end
end