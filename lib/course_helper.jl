using Gadfly

Gadfly.set_default_plot_size(1280px, 800px)

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