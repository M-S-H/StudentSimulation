include("./types.jl")
include("./monte_carlo.jl")

# Define Terms
t1 = Term([
	Course("ENGL 110", 1, 79, []),
	Course("MATH 162", 2, 69, []),
	Course("ECE 101", 3, 94, []),
	Course("ECE 131", 4, 82, []),
	Course("PHYC 160", 5, 75, [])
]);

t2 = Term([
	Course("ENGL 120", 6, 85, [1]),
	Course("MATH 163", 7, 69, [2]),
	Course("PHYC 161", 8, 82, [5]),
	Course("PHYC 161L", 9, 97, [5]),
	Course("ECE 231", 10, 92, [4])
]);

t3 = Term([
	Course("ECE 203", 11, 90, [4, 7]),
	Course("ECE 238L", 12, 86, [4]),
	Course("Basic Science", 13, 100, []),
	Course("ENGL 219", 14, 84, []),
	Course("ECON 105 or 106", 15, 77, [])
]);

t4 = Term([
	Course("ECE 206L", 16, 99, [11, 6]),
	Course("ECE 213", 17, 94, [7, 11]), 
	Course("ECE 300", 18, 98, [7]),
	Course("MATH 264", 19, 79, [7]),
	Course("ECE 330", 20, 98, [10])
]);

t5 = Term([
	Course("ECE 321L", 21, 95, [17]),
	Course("MATH 327", 22, 79, [7]),
	Course("ECE 314", 23, 92, [17, 19]),
	Course("ECE 340", 24, 90, [17, 18, 19]),
	Course("Second Language", 25, 100, [])
]);

t6 = Term([
	Course("Track Elective", 26, 100, []),
	Course("ECE 331", 27, 96, [10, 22, 24]),
	Course("ECE 344L", 28, 86, [16, 12, 21]),
	Course("Social Science", 29, 100, [])
]);

t7 = Term([
	Course("ECE 419", 30, 100, []),
	Course("ECE 437", 31, 96, [20]),
	Course("Track Elective", 32, 100, []),
	Course("Tech Elective", 33, 100, []),
	Course("Humanities", 34, 100, [])
]);

t8 = Term([
	Course("ECE 420", 35, 100, [30]),
	Course("ECE 440", 36, 97, [20, 24]),
	Course("Tech Elecitive", 37, 100, []),
	Course("Fine Arts", 38, 100, []),
	Course("Humanities", 39, 100, [])
]);

terms = [t1 t2 t3 t4 t5 t6 t7 t8];


grad_rate = simulate(20, 1, terms, 8)
println(grad_rate)
grad_rate = simulate(20, 1, terms, 10)
println(grad_rate)
grad_rate = simulate(20, 1, terms, 12)
println(grad_rate)