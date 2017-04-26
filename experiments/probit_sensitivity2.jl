using BoilingMoon
using DataFrames
using Gadfly
include("models/ProbitPassRate.jl");

curriculum = Curriculum("ComputerEngineeringDetailed", "curricula/ComputerEngineeringDetailed.json");
sim = Simulation(curriculum, model=ProbitPassRate);
students = ProbitPassRate.studentsFromFile("data/Students/en.csv", [:HSGPA, :ACTCOMP, :ACTMATH, :ACTSCIR, :ACTENGL]);

itr = 50
sem = 8

simulate(sim, students, max_credits = 18, duration = sem)
new_table = passTable(sim);

og_table = DataFrame(COUSE = new_table[:COUSE])

for i=1:sem
    key = Symbol("TERM$(i)")
    og_table[key] = zeros(curriculum.numCourses + 1)
end


baseRate = 0
baseTTG = 0
for i=1:itr
    simulate(sim, students, max_credits = 18, duration = sem)
    baseRate += sim.termGradRates[sem]
    baseTTG += sim.timeToDegree

    new_table = passTable(sim);

    for i=1:sem
        key = Symbol("TERM$(i)")
        og_table[key] = og_table[key] + new_table[key]
    end
end

baseRate /= itr
baseTTG /= itr

for i=1:sem
    key = Symbol("TERM$(i)")
    og_table[key] = og_table[key] / itr
end

results = DataFrame(name=[], original = [], new = [], cruciality=[], blocking=[], delay=[], term=[], difference = [], difference_norm= [], ediff = [], ttd=[])

for (t, term) in enumerate(curriculum.terms)
    for course in term.courses
        println(course.name)
        rate = 0
        ttd = 0

        diff_table = DataFrame(COUSE = new_table[:COUSE])

        for i=1:sem
            key = Symbol("TERM$(i)")
            diff_table[key] = zeros(curriculum.numCourses + 1)
        end

        for i=1:itr
            # sim = Simulation(curriculum, model=ProbitPassRate);
            students = ProbitPassRate.studentsFromFile("data/Students/en.csv", [:HSGPA, :ACTCOMP, :ACTMATH, :ACTSCIR, :ACTENGL]);

            course.model[:add] = 0.15
            simulate(sim, students, max_credits = 18, duration = sem)

            rate += sim.termGradRates[sem]
            ttd += sim.timeToDegree

            new_table = passTable(sim);

            for i=1:sem
                key = Symbol("TERM$(i)")
                diff_table[key] = diff_table[key] + new_table[key] - og_table[key]
            end
        end
        rate /= itr
        ttd /= itr

        e_diff = 0
        for i=1:sem
            key = Symbol("TERM$(i)")
            diff_table[key] = diff_table[key] / itr
            e_diff += sum(diff_table[key])
        end

        writetable("./results/sensitivity/probit_diff_tables/$(course.name).csv", diff_table)

        difference = round(rate - baseRate, 4)
        if difference < 0
            difference = 0
        end

        course.model[:add] = 0.0

        push!(results, [course.name, course.passrate, course.model[:add], course.cruciality, course.blocking, course.delay, t, difference, difference/t, e_diff, baseTTG - ttd])
    end
end

writetable("./results/sensitivity/$(curriculum.name)_sensitivity.csv", results)

p = plot(results, x="name", y="difference", color="cruciality", Geom.bar);
draw(PNG("./results/sensitivity/$(curriculum.name).png", 1920px, 1080px), p);


# println("Complexity: $(curriculum.complexity)")
# println(passTable(sim))
# println("\n")

# using BoilingMoon
# using DataFrames
# include("models/ProbitPassRate.jl");

# curriculum = Curriculum("ComputerEngineeringDetailed", "curricula/ComputerEngineeringDetailed.json");
# sim = Simulation(curriculum, model=ProbitPassRate);
# students = ProbitPassRate.studentsFromFile("data/Students/en.csv", [:HSGPA, :ACTCOMP, :ACTMATH, :ACTSCIR, :ACTENGL]);

# itr = 10
# sem = 10

# simulate(sim, students, max_credits = 18, duration = sem)
# new_table = passTable(sim);

# og_table = DataFrame(COUSE = new_table[:COUSE])

# for i=1:sem
#     key = Symbol("TERM$(i)")
#     og_table[key] = zeros(curriculum.numCourses + 1)
# end

# baseRate = 0
# baseTTG = 0
# for i=1:itr
#     simulate(sim, students, max_credits = 18, duration = sem)
#     baseRate += sim.termGradRates[sem]
#     baseTTG += sim.timeToDegree

#     new_table = passTable(sim);

#     for i=1:sem
#         key = Symbol("TERM$(i)")
#         og_table[key] = og_table[key] + new_table[key]
#     end
# end

# for i=1:sem
#     key = Symbol("TERM$(i)")
#     og_table[key] = og_table[key] / itr
# end

# baseRate /= itr
# baseTTG /= itr

# original = map(x->(x.enrolled - x.failures)/x.enrolled, curriculum.courses)

# results = DataFrame(name=[], actual = [], original = [], new = [], cruciality=[], term=[], difference = [], ttd=[])
# results2 = DataFrame(name=[], actual = [], original = [], new = [], cruciality=[], term=[], difference = [], ttd=[])

# for (t, term) in enumerate(curriculum.terms)
#     for course in term.courses
#         rate = 0
#         ttd = 0
#         for i=1:itr
#             sim = Simulation(curriculum, model=ProbitPassRate);
#             students = ProbitPassRate.studentsFromFile("data/Students/en.csv", [:HSGPA, :ACTCOMP, :ACTMATH, :ACTSCIR, :ACTENGL]);
#             course.model[:add] = 0.15
#             simulate(sim, students, max_credits = 18, duration = sem)
#             rate += sim.termGradRates[sem]
#             ttd += sim.timeToDegree
#         end
#         rate /= itr
#         ttd /= itr

#         push!(results, [course.name, course.passrate, 0, (course.enrolled - course.failures) / course.enrolled, course.cruciality, t, round(rate - baseRate, 4), baseTTG - ttd])
#         push!(results2, [course.name, course.passrate, 0, (course.enrolled - course.failures) / course.enrolled, course.cruciality, t, round(rate - baseRate, 4)/t, baseTTG - ttd])
#     end
# end

# results[:original] = original
# results2[:original] = original

# writetable("./results/simple_sensitivity_$(curriculum.name).csv", results)
# writetable("./results/simple_sensitivity_$(curriculum.name)2.csv", results2)


# # println("Complexity: $(curriculum.complexity)")
# # println(passTable(sim))
# # println("\n")