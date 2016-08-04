course1 = Course("Course One", 3, 0.9, Course[])
course2 = Course("Course Two", 3, 0.9, Course[])

course3 = Course("Course Three", 3, 0.9, [course1])
course4 = Course("Course Four", 3, 0.9, [course1])
course5 = Course("Course Five", 3, 0.9, [course1])
course6 = Course("Course Six", 3, 0.9, [course2])
course7 = Course("Course Seven", 3, 0.9, [course2])


# Define Terms
term1 = Term([course1, course2])
term2 = Term([course3, course4, course5, course6, course7])

terms = [term1, term2]