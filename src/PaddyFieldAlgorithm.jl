module PaddyFieldAlgorithm

export Solution
export SolutionFactory
export fitness

export distance
export create_solution

include("Parameter.jl")
include("Solution.jl")
include("Extrema.jl")
include("Regression.jl")
include("Optimize.jl")

end # module
