addprocs(8)

@everywhere using BoilingMoon
@everywhere using DataFrames
using Gadfly

# Simulation Variables
@everywhere numStudents = 1000
@everywhere ittertations = 20
@everywhere semesters = 1000
@everywhere reportSem = 8
@everywhere passTableSems = 8

baseCurriculum = Curriculum("Accounting", "curricula/Accounting.json");
baseSimulation = Simulation(baseCurriculum);

# Simulation Function
@everywhere function perform_simulation(i)
    # Load the curriculum
    curriculum = Curriculum("Accounting", "curricula/Accounting.json");
    sim = Simulation(curriculum);

    # Increase Passrate
    if i > 0
        curriculum.courses[i].model[:passrate] *= 1.3

        if curriculum.courses[i].model[:passrate] > 1
            curriculum.courses[i].model[:passrate] = 1
        end
    end

    students = defaultStudents(numStudents);
    simulate(sim, students, max_credits = 18, duration = semesters)
    return sim
end


# Perform Baseline Simulations
simulations = pmap(perform_simulation, zeros(ittertations))

# Original PassRate Table
original_table = DataFrame(COUSE = map(x->x.name, baseCurriculum.courses));
push!(original_table, ["GRAD RATE"])
for i=1:passTableSems
    key = Symbol("TERM$(i)")
    original_table[key] = zeros(baseCurriculum.numCourses + 1)
end

# Reduce Results
baseRate = 0
baseTTD = 0
for sim in simulations
    # Sum Grad Rates
    baseRate += sim.termGradRates[reportSem];

    # Sum Time To Degree
    baseTTD += sim.timeToDegree

    # Sum Course Passrates
    new_table = passTable(sim, passTableSems);

    for i=1:passTableSems
        key = Symbol("TERM$(i)")
        original_table[key] = original_table[key] + new_table[key]
    end
end

# Average Grad Rates and TTD
baseRate /= ittertations
baseTTD /= ittertations

# Average Course Passrates
for i=1:passTableSems
    key = Symbol("TERM$(i)")
    original_table[key] = original_table[key] / ittertations
end

# Results
results = DataFrame(name=[], original=[], new=[], cruciality=[], blocking=[], delay=[], term=[], difference=[], difference_norm=[], ediff=[], ttd=[])

# Itterate over all courses
for (t, term) in enumerate(baseCurriculum.terms)
    for (c, course) in enumerate(term.courses)
        println(course.name)

        # Perform Simulations
        simulations = pmap(perform_simulation, [course.id for i=1:ittertations])

        # PA
        rate = 0
        ttd = 0

        diff_table = DataFrame(COUSE = original_table[:COUSE])

        for i=1:passTableSems
            key = Symbol("TERM$(i)")
            diff_table[key] = zeros(baseCurriculum.numCourses + 1)
        end

        for sim in simulations
            rate += sim.termGradRates[reportSem]
            ttd += sim.timeToDegree

            new_table = passTable(sim, passTableSems)

            for i=1:passTableSems
                key = Symbol("TERM$(i)")
                diff_table[key] = diff_table[key] + new_table[key]
            end
        end

        rate /= ittertations
        ttd /= ittertations

        e_diff = 0
        for i=1:passTableSems
            key = Symbol("TERM$(i)")
            diff_table[key] = diff_table[key] / ittertations
            diff_table[key] = diff_table[key] - original_table[key]
            e_diff += sum(diff_table[key])
        end

        writetable("./results/sensitivity/diff_tables/$(baseCurriculum.name)/$(course.name).csv", diff_table)

        difference = round(rate - baseRate, 4)
        if difference < 0
            difference = 0
        end

        new_passrate = course.passrate * 1.3
        if new_passrate > 1
            new_passrate = 1.0
        end

        push!(results, [course.name, round(course.passrate, 4), round(new_passrate, 4), course.cruciality, course.blocking, course.delay, t, difference, difference/t, e_diff, baseTTD-ttd])
    end
end

writetable("./results/sensitivity/$(baseCurriculum.name)_sensitivity.csv", results)

p = plot(results, x="name", y="difference", color="cruciality", Geom.bar);
draw(PNG("./results/sensitivity/$(baseCurriculum.name).png", 1920px, 1080px), p);