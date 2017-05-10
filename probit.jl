using CASL
include("models/ProbitPassRate.jl");
using ProbitPassRate

curriculumName = "ComputerEngineeringDetailed";

curriculum = Curriculum(curriculumName, "curricula/$(curriculumName).json");

students = ProbitPassRate.studentsFromFile("data/Students/cpe_entry_2009.csv", [:HSGPA, :ACTCOMP, :ACTMATH, :ACTSCIR, :ACTENGL]);

sim = simulate(curriculum, students, max_credits = 15, duration=12, stopouts=true);

println(sim.termGradRates)