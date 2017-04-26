using BoilingMoon
using DataFrames
using Gadfly

curriculum = Curriculum("ComputerEngineering", "curricula/ComputerEngineering.json")
sim = Simulation(curriculum)
numStudents = 1000
students = defaultStudents(numStudents);

itr = 20
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
    students = defaultStudents(numStudents);
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
            sim = Simulation(curriculum);
            students = defaultStudents(numStudents);
            course.model[:passrate] *= 1.2
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

        writetable("./results/sensitivity/diff_tables/$(course.name).csv", diff_table)

        difference = round(rate - baseRate, 4)
        if difference < 0
            difference = 0
        end

        push!(results, [course.name, course.passrate, course.model[:passrate], course.cruciality, course.blocking, course.delay, t, difference, difference/t, e_diff, baseTTG - ttd])
    end
end

writetable("./results/sensitivity/$(curriculum.name)_sensitivity.csv", results)

p = plot(results, x="name", y="difference", color="cruciality", Geom.bar);
draw(PNG("./results/sensitivity/$(curriculum.name).png", 1920px, 1080px), p);


# println("Complexity: $(curriculum.complexity)")
# println(passTable(sim))
# println("\n")