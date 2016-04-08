ece203 = Course("ECE203", 3, Course[])
math163 = Course("MATH163", 3, Course[])
ece213 = Course("ECE213", 3, [ece203, math163])

t1 = Term([ece203, math163])
t2 = Term([ece213])

terms = [t1, t2]

features = [:GPA]