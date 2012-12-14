result = 
{
	:attacker => {
		:owner_info => {},
		:army => [],
		:buff_info => {}
	},

	:defender => {
		:owner_info => {},
		:army => [],
		:buff_info => {}
	}

	:from_where => {},
	:to_where => {},

	:winner => 'attacker',
	:total_rounds => 10,

	:rounds => [
		[
			{
				:attacker_id => 1,
				:target_id => 2,
				:skills => [
					:type => 3,
					:level => 1
				],
				:damage => 55
			},

			{
				:attacker_id => 2,
				:target_id => 3,
				:skills => [
					:type => 5,
					:level => 2
				],
				:damage => 49
			}
		]
	]
}

result: _battle_result_data
	attacker: _army_data
		owner_info: _owner_data
			owner_type: string["player", "gold_mine", "village"]
			owner_id: int
			
	defender: _army_data

	total_rounds: int
	winner: string["attacker", "defender"]
	all_rounds: array
		[
			data1: _single_round_data
				attacker_id: int
				target_id: int
				damage: int
			data2: _single_round_data
			data3: _single_round_data
			...
		]













