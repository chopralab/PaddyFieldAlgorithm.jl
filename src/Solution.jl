"""
A `Solution` is optimized by the Paddy algorithm to maximize *fitness*.

This is an `abstract type` which is implemented by structures which provide
an expression to *solve* a given problem (currently just regression). The
method in which the *fitness* of a `Solution` is calculated is dependant on
the type of problem the `Solution` solves (eg MSE for regression).

A `Solution` is comprised of one or more `ParameterValue` s which represent
how the `Solution` is evaluated. The algorithm attempts to modify the
`ParameterValue` s value to optimize the fitness of the `Solution`.
"""
abstract type Solution end

"""
Calculates the distance between `Solution` s1 and `Solution` s2

The Paddy algorithm uses the *distance* between solutions to calculate the
number of neighbors a given `Solution` has and scale the fitness value
accordingly. See the `pollinate` function for details.
"""
distance(s1::Solution, s2::Solution) = 0.0

"""
A `SolutionFactory` initializes and propogates a `Solution`

Internally, a `SolutionFactory` consists of `Parameter` s which define rules on
how to create and modify `ParameterValue` s in a given `Solution`.
"""
abstract type SolutionFactory end

"""
Initializes a random `Solution`

This function is used to generate random `Solution` s so that they can be
used to propogate new `Solution` s.
"""
create_solution(s::SolutionFactory) = 0.0

"""
Randomly create a new `Solution` from an existing `Solution`
"""
propagate_solution(sf::SolutionFactory, sl::Solution) = 0.0
