features = [:HSGPA, :ACTENGL]

engl = Course("ENGL110", 3, Course[])
students = courseStudents(engl, features)

GaussianBayes.train(engl, features)

predictions = []
for s in students
	grade = GaussianBayes.predict(engl, s.features')
	push!(predictions, grade)
end


engl1 = Course("ENGL110", 3, Course[])
engl2 = Course("ENGL110", 3, [engl1])

t1 = Term([engl1])
t2 = Term([engl2])

terms = [t1, t2]