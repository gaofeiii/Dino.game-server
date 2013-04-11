module PlayerSerialTaskHelper
	module ClassMethods
		
	end
	
	module InstanceMethods

		module SingleTaskHelper

		end

		module TasksHelper

			def find_by_idx(index)
				return nil if index <= 20000

				self.each do |task|
					return task if task.index == index
				end
			end

		end

		def all_serial_tasks
			serial_tasks.to_a.map do |task|
				task.extend(SingleTaskHelper)
			end.extend(TasksHelper)
		end
		
		def my_serial_tasks
			# 1 create missing tasks
			missing_indices = SerialTask.all_indices - serial_tasks.map(&:index)
			missing_indices.each do |t_index|
				SerialTask.create(:index => t_index, :player_id => id)
			end

			# 2 find unfinished or unrewarded tasks which forward task is finished && rewarded
			all_tasks = all_serial_tasks

			visible_tasks = []

			all_tasks.each do |task|
				if task.finished
					visible_tasks << task if task.not_rewarded
				else
					# visible_tasks << task if task.not_finished && task.forward_task_rewarded
					if task.not_finished
						forward_task = all_tasks.find_by_idx(task.forward_index)
						visible_tasks << task if !forward_task || forward_task.is_rewarded
					end
				end
			end

			visible_tasks
		end

		def find_serial_task_by_index(idx)
			serial_tasks.find(:index => idx).first
		end

	end
	
	def self.included(model)
		model.collection :serial_tasks, 	SerialTask
		model.attribute  :serial_tasks_data, 	Ohm::DataTypes::Type::SmartHash

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end