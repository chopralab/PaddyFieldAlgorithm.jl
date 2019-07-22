module PaddyFieldAlgorithm

export Solution
export SolutionFactory

export distance
export create_solution

"A `Solution` is optimized by the Paddy algorithm to maximize fitness"
abstract type Solution end

"Calculates the distance between `Solution` s1 and `Solution` s2."
distance(s1::Solution, s2::Solution) = 0.0

"A `SolutionFactory` initialize and mutates a `Solution` randomly."
abstract type SolutionFactory end

"initializes a random `Solution`."
create_solution(s::SolutionFactory) = 0.0

include("Parameter.jl")
include("Regression.jl")
include("Optimize.jl")

end # module
