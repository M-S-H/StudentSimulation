using BoilingMoon
using Gadfly
include("models/ProbitPassRate.jl");

curricula = ["ComputerEngineeringDetailed"] #, "AccountingDetailed"]

c = "AccountingDetailed"
# for c in curricula
    curriculum = Curriculum(c, "curricula/$(c).json");
    println(c)
    
    sim = Simulation(curriculum, model=ProbitPassRate);

a = 0
b = 0
c = 0

    for i=1:1000
        students = ProbitPassRate.studentsFromFile("data/Students/bba_entry_2008.csv", [:HSGPA, :ACTCOMP, :ACTMATH, :ACTSCIR, :ACTENGL]);
        simulate(sim, students, max_credits = 18, duration = 12, stopouts = true);
        a += sim.termGradRates[8]
        b += sim.termGradRates[10]
        c += sim.termGradRates[12]
        #println("$(round(sim.termGradRates[8], 2))\t$(round(sim.termGradRates[10], 2))\t$(round(sim.termGradRates[12], 2))")
        #println("$(round(sim.termStopoutRates[8], 2))\t$(round(sim.termStopoutRates[10], 2))\t$(round(sim.termStopoutRates[12], 2))\n")
    end

    a /= 1000
    b /= 1000
    c /= 1000

    println("$(round(a, 2))\t$(round(b, 2))\t$(round(c, 2))")



    # students = ProbitPassRate.studentsFromFile("data/Students/cpe_entry_2009.csv", [:HSGPA, :ACTCOMP, :ACTMATH, :ACTSCIR, :ACTENGL]);
    # simulate(sim, students, max_credits = 18, duration = 12, stopouts = true);
    # println("$(round(sim.termGradRates[8], 2))\t$(round(sim.termGradRates[10], 2))\t$(round(sim.termGradRates[12], 2))")
    # println("$(round(sim.termStopoutRates[8], 2))\t$(round(sim.termStopoutRates[10], 2))\t$(round(sim.termStopoutRates[12], 2))\n")

    # for student in students
    #     student.attributes[:HSGPA] -= 0.2
    #     student.attributes[:ACTCOMP] -= 2
    #     student.attributes[:ACTMATH] -= 2
    #     student.attributes[:ACTSCIR] -= 2
    #     student.attributes[:ACTENGL] -= 2
    # end

    # simulate(sim, students, max_credits = 18, duration = 12, stopouts = true);
    # println("$(round(sim.termGradRates[8], 2))\t$(round(sim.termGradRates[10], 2))\t$(round(sim.termGradRates[12], 2))")
    # println("$(round(sim.termStopoutRates[8], 2))\t$(round(sim.termStopoutRates[10], 2))\t$(round(sim.termStopoutRates[12], 2))\n")

    # for student in students
    #     student.attributes[:HSGPA] += 0.4
    #     student.attributes[:ACTCOMP] += 4
    #     student.attributes[:ACTMATH] += 4
    #     student.attributes[:ACTSCIR] += 4
    #     student.attributes[:ACTENGL] += 4
    # end

    # simulate(sim, students, max_credits = 18, duration = 12, stopouts = true);
    # println("$(round(sim.termGradRates[8], 2))\t$(round(sim.termGradRates[10], 2))\t$(round(sim.termGradRates[12], 2))")
    # println("$(round(sim.termStopoutRates[8], 2))\t$(round(sim.termStopoutRates[10], 2))\t$(round(sim.termStopoutRates[12], 2))\n")
# end