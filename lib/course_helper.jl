using Gadfly

Gadfly.set_default_plot_size(1280px, 800px)

function cruciality(course)
	b = blocking(course)
	d = delay(course)

	course.blocking = b
	course.delay = d
	course.cruciality = d + b
end

function blocking(course, b=-1, courses=[])

	for c in course.postreqs
		b += blocking(c, 0, courses)
	end

	if !in(course.name, courses) 
		b += 1
		push!(courses, course.name)
	end

	return b
end

function delay(course)
	# Forward
	f = []
	forward(course, f)

	# Backward
	b = []
	backward(course, b)

	return maximum(f) + maximum(b) + 1
end

function forward(course, paths, l=0)
	for c in course.postreqs
		forward(c, paths, l+1)
	end

	if length(course.postreqs) == 0
		push!(paths, l)
	end
end

function backward(course, paths, l=0)
	for c in course.prereqs
		backward(c, paths, l+1)
	end

	if length(course.prereqs) == 0
		push!(paths, l)
	end
end


function gradeHistActual(course)
	plot(x=course.model[:Y], Geom.histogram)
end


function gradeHistSimulated(course)
	plot(x=course.grades, Geom.histogram)
end


function gradeProb(course)
end


function passScatterActual(course)
	labels = map(x -> x >= 1.67 ? "pass" : "fail", course.model[:Y])
	plot(x=course.model[:X][:,1], y=course.model[:X][:,2], color=labels)
end


function passScatterSim(course)
	labels = map(x -> x >= 1.67 ? "pass" : "fail", course.model[:predictions])
	plot(x=course.model[:X][:,1], y=course.model[:X][:,2], color=labels)
end