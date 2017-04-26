# server.jl
include("SimulationModel.jl");

using HttpServer
using JSON

function runsim(data)
  curriculum = Curriculum(data)
  students = passRateStudents(10000)
  sim = Simulation(curriculum, [], [], PassRate);
  simulate(sim, students, max_credits = 9, numTerms = 4, stopouts = false, locked_terms = false);
  simJSON(sim)
end

function computeComplexity(data)
  curriculum = Curriculum(data)
  response = Dict(
    "complexity" => curriculum.complexity,
    "delay" => curriculum.delay,
    "blocking" => curriculum.blocking
  )
  return JSON.json(response)
end

http = HttpHandler() do req::Request, res::Response
  if ismatch(r"/studentsim", req.resource)
    data = JSON.parse(bytestring(req.data))
    return Response(runsim(data))
  elseif ismatch(r"/complexity", req.resource)
    data = JSON.parse(bytestring(req.data))
    println(req.data)
    return Response(computeComplexity(data))
  else
    return Response("Not Found")
  end
end

server = Server(http)
run(server, 8000)