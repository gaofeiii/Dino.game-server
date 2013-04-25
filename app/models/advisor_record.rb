class AdvisorRecord < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	TYPES = {:produce => 1, :military => 2, :business => 3, :technology => 4}
	
	attribute :type,				Type::Integer
	attribute :price,				Type::Integer
	attribute :player_id,		Type::Integer
	attribute :is_npc,			Type::Boolean

	index :type
	index :player_id

	class << self

		def types
			TYPES
		end

		def find_by_player_id(p_id)
			find(:player_id => p_id).first
		end

		def list(type: 0, count: 10)
			find(:type => type).sort(:limit => [0, count])
		end

		def create_npc
			Player.npc.to_a.each_with_index do |npc, idx|
				npc_record = self.find(:player_id => npc.id).first
				if npc_record.blank?
					npc_record = self.create :type => idx + 1, :price => 1000, :player_id => npc.id, :is_npc => true
				else
					npc_record.update :type => idx + 1
				end
			end
		end
		
	end

	def player
		Player[player_id]
	end

	# 顾问的评分
	def evaluation
		@player = self.player

		case type
		when TYPES[:produce]
			(@player.tech_produce_wood_rate + @player.tech_produce_stone_rate) / 2
		when TYPES[:military]
			@player.honour_score
		when TYPES[:business]
			@player.is_npc? ? 100 : @player.gold_mines.sum { |mine| mine.output }.to_i
		when TYPES[:technology]
			@player.techs.map(&:level).max.to_i
		else
			0
		end
	end

	def to_hash
		@player = player
		{
			:type => type,
			:price => price,
			:player_id => player_id,
			:nickname => @player.nickname,
			:level => @player.level,
			:avatar_id => @player.avatar_id,
			:days => 1,
			:evaluation => evaluation
		}
	end

	def after_create
		player.set :advisor_record_id, id
	end
end