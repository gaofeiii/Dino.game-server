class SerialTask < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	include BasicTask
	include SerialTaskConst

	reference :player, 	Player

	def to_hash
		{
			:number => index,
		  :rewarded => rewarded,
		  :finished_steps => 0,
		  :total_steps => 1,
		  :goal=> "主线任务1",
		  :level => 3,
		  :reward => {
		  	:item_cat=>3,
		    :item_type=>1,
		    :item_count=>1,
		    :xp=>200,
		    :egg_quality=>0,
		    :gold_coin=>5000
		    },
		  :x=>327,
		  :y=>873
		}	
	end

	def not_finished
		!finished
	end

	def not_rewarded
		!rewarded
	end

	def is_finished
		finished
	end

end