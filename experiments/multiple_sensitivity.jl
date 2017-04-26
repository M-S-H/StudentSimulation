addprocs(8)

@everywhere using BoilingMoon
@everywhere using DataFrames
using Gadfly

# Simulation Variables
@everywhere numStudents = 100
@everywhere ittertations = 20
@everywhere semesters = 8

baseCurriculum = Curriculum("ComputerEngineering", "curricula/ComputerEngineering.json")

# Simulation Function
@everywhere function perform_simulation(i)
    # Load the curriculum
    curriculum = Curriculum("ComputerEngineering", "curricula/ComputerEngineering.json");
    sim = Simulation(curriculum);

    # Increase Passrate
    if i[1] > 0
        curriculum.courses[i[1]].model[:passrate] *= 1.3
        curriculum.courses[i[2]].model[:passrate] *= 1.3

        if curriculum.courses[i[1]].model[:passrate] > 1
            curriculum.courses[i[1]].model[:passrate] = 1
        end

        if curriculum.courses[i[2]].model[:passrate] > 1
            curriculum.courses[i[2]].model[:passrate] = 1
        end
    end

    students = defaultStudents(numStudents);
    simulate(sim, students, max_credits = 18, duration = semesters)
    return sim
end


# Perform Baseline Simulations
simulations = pmap(perform_simulation, [(0,0) for i=1:ittertations])

# Original PassRate Table
original_table = DataFrame(COUSE = map(x->x.name, baseCurriculum.courses));
push!(original_table, ["GRAD RATE"])
for i=1:semesters
    key = Symbol("TERM$(i)")
    original_table[key] = zeros(baseCurriculum.numCourses + 1)
end

# Reduce Results
baseRate = 0
for sim in simulations
    # Sum Grad Rates
    baseRate += sim.termGradRates[semesters];

    # Sum Course Passrates
    new_table = passTable(sim);

    for i=1:semesters
        key = Symbol("TERM$(i)")
        original_table[key] = original_table[key] + new_table[key]
    end
end

# Average Grad Rates
baseRate /= ittertations

# Average Course Passrates
for i=1:semesters
    key = Symbol("TERM$(i)")
    original_table[key] = original_table[key] / ittertations
end

# Results
results = DataFrame(name=[], cruciality=[], blocking=[], delay=[], difference=[], difference_norm=[], ediff=[])

termMap = Dict()
for (t, term) in enumerate(baseCurriculum.terms)
    for (c, course) in enumerate(term.courses)
        termMap[course.name] = t
    end
end

for one=1:baseCurriculum.numCourses
    for two=1:baseCurriculum.numCourses
        println("$(one), $(two)")

        course1 = baseCurriculum.courses[one];
        course2 = baseCurriculum.courses[two];

        name = "$(course1.name), $(course2.name)"
        cruciality = course1.cruciality + course2.cruciality
        delay = course1.delay + course2.delay
        blocking = course1.blocking + course2.blocking

        simulations = pmap(perform_simulation, [(one,two) for k=1:ittertations])

        # PA
        rate = 0

        diff_table = DataFrame(COUSE = original_table[:COUSE])

        for i=1:semesters
            key = Symbol("TERM$(i)")
            diff_table[key] = zeros(baseCurriculum.numCourses + 1)
        end

        for sim in simulations
            rate += sim.termGradRates[semesters]

            new_table = passTable(sim)

            for i=1:semesters
                key = Symbol("TERM$(i)")
                diff_table[key] = diff_table[key] + new_table[key]
            end
        end

        rate /= ittertations

        e_diff = 0
        for i=1:semesters
            key = Symbol("TERM$(i)")
            diff_table[key] = diff_table[key] / ittertations
            diff_table[key] = diff_table[key] - original_table[key]
            e_diff += sum(diff_table[key])
        end

        # writetable("./results/sensitivity/diff_tables/$(course.name).csv", diff_table)

        difference = round(rate - baseRate, 4)
        if difference < 0
            difference = 0
        end

        termnums = termMap[course1.name]
        termnums += termMap[course2.name]

        push!(results, [name, cruciality, blocking, delay, difference, difference/termnums, e_diff])
    end
end

writetable("./results/sensitivity/$(baseCurriculum.name)_multiple_sensitivity.csv", results)