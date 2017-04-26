addprocs(8)

@everywhere using BoilingMoon
@everywhere using DataFrames
@everywhere include("models/ProbitPassRate.jl");
using Gadfly

# Simulation Variables
@everywhere numStudents = 1000
@everywhere ittertations = 2
@everywhere semesters = 8

@everywhere baseCurriculum = Curriculum("ComputerEngineeringDetailed", "curricula/ComputerEngineeringDetailed.json");
@everywhere baseSimulation = Simulation(baseCurriculum, model=ProbitPassRate);
# Simulation Function
@everywhere function perform_simulation(i)
    # Load the curriculum
    dummy_curriculum = Curriculum("ComputerEngineeringDetailed", "curricula/ComputerEngineeringDetailed.json");
    sim = Simulation(dummy_curriculum);
    sim.curriculum = deepcopy(baseCurriculum);
    sim.predictionModel = ProbitPassRate;

    # Increase Passrate
    if i > 0
        sim.curriculum.courses[i].model[:add] = 0.2
    end

    students = ProbitPassRate.studentsFromFile("data/Students/en.csv", [:HSGPA, :ACTCOMP, :ACTMATH, :ACTSCIR, :ACTENGL]);
    simulate(sim, students, max_credits = 18, duration = semesters)
    return sim
end


# Perform Baseline Simulations
simulations = pmap(perform_simulation, zeros(ittertations))

# Original PassRate Table
original_table = DataFrame(COUSE = map(x->x.name, baseCurriculum.courses));
push!(original_table, ["GRAD RATE"])
for i=1:semesters
    key = Symbol("TERM$(i)")
    original_table[key] = zeros(baseCurriculum.numCourses + 1)
end

# Reduce Results
baseRate = 0
original_rates = zeros(baseCurriculum.numCourses)
for sim in simulations
    # Sum Grad Rates
    baseRate += sim.termGradRates[semesters];

    # Sum Course Passrates
    new_table = passTable(sim);

    for i=1:semesters
        key = Symbol("TERM$(i)")
        original_table[key] = original_table[key] + new_table[key]
    end

    for (c, course) in enumerate(sim.curriculum.courses)
        original_rates[c] += (course.enrolled - course.failures) / course.enrolled
    end
end

# Average Grad Rates
baseRate /= ittertations

# Average Course Passrates
for i=1:semesters
    key = Symbol("TERM$(i)")
    original_table[key] = original_table[key] / ittertations
end

original_rates = original_rates / ittertations

# Results
results = DataFrame(name=[], original=[], new=[], cruciality=[], blocking=[], delay=[], term=[], difference=[], difference_norm=[], ediff=[])

# Itterate over all courses
new_rates = zeros(baseCurriculum.numCourses)
for (t, term) in enumerate(baseCurriculum.terms)
    for (c, course) in enumerate(term.courses)
        println(course.name)

        # Perform Simulations
        simulations = pmap(perform_simulation, [c for i=1:ittertations])

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

            for (ci, course) in enumerate(sim.curriculum.courses)
                new_rates[ci] += (course.enrolled - course.failures) / course.enrolled
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

        writetable("./results/sensitivity/probit_diff_tables/$(course.name).csv", diff_table)

        difference = round(rate - baseRate, 4)
        if difference < 0
            difference = 0
        end

        push!(results, [course.name, round(course.passrate, 4), round(course.passrate * 1.2, 4), course.cruciality, course.blocking, course.delay, t, difference, difference/t, e_diff])
    end
end

new_rates = new_rates / ittertations
results[:original] = original_rates
results[:new] = new_rates

writetable("./results/sensitivity/$(baseCurriculum.name)_sensitivity.csv", results)

p = plot(results, x="name", y="difference", color="cruciality", Geom.bar);
draw(PNG("./results/sensitivity/$(baseCurriculum.name).png", 1920px, 1080px), p);