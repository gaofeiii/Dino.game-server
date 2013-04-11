module PlayerSerialTaskHelper
	module ClassMethods
		
	end
	
	module InstanceMethods

		module TasksHelper

			def find_by_idx(index)
				self.each do |task|
					return task if task.index == index
				end
			end
		end
		
		def my_serial_tasks
			# 1 create missing tasks
			missing_indices = SerialTask.all_indices - serial_tasks.ids.map!(&:to_i)
			missing_indices.each do |t_index|
				SerialTask.create(:index => t_index, :player_id => id)
			end

			# 2 find unfinished or unrewarded tasks which forward task is finished && rewarded
			all_tasks = serial_tasks.to_a.extend(TasksHelper)
			visible_tasks = []

			all_tasks.each do |task|
				if task.finished
					visible_tasks << task if task.not_rewarded
				else
					# visible_tasks << task if task.not_finished && task.forward_task.rewarded
				end
			end
		end
	end
	
	def self.included(model)
		model.collection :serial_tasks, 	SerialTask

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end