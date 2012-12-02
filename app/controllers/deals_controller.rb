class DealsController < ApplicationController
	before_filter :validate_player, :only => [:buy, :sell]

	def list
		
	end

	def buy
		
	end

	def sell
		g_type = params[:type].to_i
		case g_type
		when Deal.types[:res]

		when Deal.types[:egg]

		else
			{
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("wrong type of goods")
			}
		end
	end
end
