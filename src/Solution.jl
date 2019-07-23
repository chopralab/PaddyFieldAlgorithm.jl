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
    create_solution(sf)

This function is used to generate a random `Solution`.

# Examples
```julia-repl
julia> sf = LinearSolutionFactory();
julia> create_solution(sf)
y(x) = 4.403384493734293*x + -86.10091661533485
```
"""
create_solution(sf::SolutionFactory) = 0.0

"""
    propagate_solution(sf, sl)

Create a new `Solution` from an existing `Solution`. Typically, the new
solution is generated randomly from the old solution.

# Examples
```julia-repl
julia> sf = LinearSolutionFactory();
julia> sl = create_solution(s);
julia> propagate_solution(sf, sl)
y(x) = 8.649846062840627*x + 52.23236375794089
```
"""
propagate_solution(sf::SolutionFactory, sl::Solution) = 0.0
