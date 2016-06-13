module Retention

	function train()
	end


	function predict(semester)
		rate = 0.10

		if semester == 1
			rate = 0.045
		elseif semester == 2
			rate = 0.11
		elseif semester == 3
			rate = 0.047
		elseif semester == 4
			rate = 0.11
		elseif semester == 5
			rate = 0.03
		elseif semester == 6
			rate = 0.06
		elseif semester == 7
			rate = 0.08
		elseif semester == 8
			rate = 0.05
		end

		roll = rand()
		if roll <= rate
			return true
		else
			return false
		end
	end
end