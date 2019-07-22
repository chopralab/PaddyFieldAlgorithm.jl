module PaddyFieldAlgorithm

export Solution
export SolutionFactory

export distance
export create_solution

include("Parameter.jl")
include("Solution.jl")
include("Regression.jl")
include("Optimize.jl")

end # module
