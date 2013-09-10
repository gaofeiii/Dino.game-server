module PlayerWorkersHelper
	module ClassMethods
		
	end
	
	module InstanceMethods

		# The queue has already been used.
		def curr_action_queue_size
			vil = village
			bd_queue_size = vil.buildings.find(:status => Building::STATUS[:new]).size + vil.buildings.find(:status => Building::STATUS[:half]).size
			tech_queue_size = 0#technologies.find(:status => Technology::STATUS[:researching]).size
			bd_queue_size + tech_queue_size
		end

		# The size of building or researching queue.
		def action_queue_size
			# bd_size = village.buildings.find(:type => Building.hashes[:residential], :status => Building::STATUS[:finished]).size
			# self.tech_worker_number * bd_size
			4
		end

		def curr_research_queue_size
			technologies.find(:status => Technology::STATUS[:researching]).size
		end

		def total_research_queue_size
			village.buildings.find(:type => Building.hashes[:workshop]).size
		end

		# 当前拥有的worker总数：民居数×科技
	  def total_workers
	  	vil = Village.new :id => village_id
	  	tech_worker_number * vil.buildings.find(:type => Building.hashes[:residential]).size
	  end

	  # 当前正在工作的worker数
	  def working_workers
	  	vil = Village.new :id => village_id
	  	vil.buildings.find(:has_worker => 1).size
	  end

	  def need_workers
	  	vil = Village.new :id => village_id
	  	vil.buildings.find(:resource_building => true).size
	  end

	  def update_building_workers!
	  	vil = Village.new :id => village_id
	  	total = total_workers
	  	vil.buildings.find(:resource_building => true).each do |bd|
	  		if total > 0
	  			bd.update(:has_worker => 1)
	  			total -= 1
	  		else
	  			bd.update(:has_worker => 0)
	  		end
	  	end
	  end
	  
	end
	
	def self.included(model)
		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end