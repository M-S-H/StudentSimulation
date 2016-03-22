type Course
	name
	id::Int
	rate::Float64
	failed::Int
	prereqs::Array{Int}
	students::Array{Int}

	Course(n, id, prereqs) = new(n, id, 100.0, 0.0, prereqs, [])
	Course(n, id, rate, prereqs) = new(n, id, rate, 0.0, prereqs, [])
end

type Term
	courses::Array{Course}
end