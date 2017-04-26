using BoilingMoon
using DataFrames
using Gadfly
using GLM

results = DataFrame(Curriculum=[], CoursePassRate=[], Complexity=[], GradRate4Terms=[], GradRate5Terms=[], GradRate6Terms=[], GradRate7Terms=[])

curricula = ["WrightStateOld", "WrightStateNew"]

passRates = [0.5, 0.6, 0.7, 0.8, 0.9]

for rate in passRates
    println(rate)
    for c in curricula
        println(c)

        curriculum = Curriculum(c, "curricula/$(c).json")
        rates = [0,0,0,0]

        for i=1:100
            sim = Simulation(curriculum)
            setPassrates(curriculum.courses, rate);
            students = defaultStudents(100)
            simulate(sim, students, max_credits = 9, duration = 7)
            rates += sim.termGradRates[4:7]
        end

        rates /= 100

        push!(results, [c rate curriculum.complexity round(rates, 2)'])
    end
end

for c in curricula
    println(c)

    curriculum = Curriculum(c, "curricula/$(c).json")
    rates = [0,0,0,0]

    for i=1:100
        sim = Simulation(curriculum)
        curriculum.courses[1].model[:passrate] *= 1.05
        students = defaultStudents(100)
        simulate(sim, students, max_credits = 9, duration = 7)
        rates += sim.termGradRates[4:7]
    end

    rates /= 100

    push!(results, [c "Actual" curriculum.complexity round(rates, 2)'])
end

writetable("./results/wrightState.csv", results)