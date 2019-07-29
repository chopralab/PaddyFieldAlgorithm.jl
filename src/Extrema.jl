export ExtremaSolution,
       ExtremaSolutionFactory

struct ExtremaSolution <: Solution
    inputs :: Vector{ParameterValue}
end

fitness(s::ExtremaSolution, f::Function) = f(Real.(s.inputs)...)

distance(s1::ExtremaSolution, s2::ExtremaSolution) = sum((Real.(s1.inputs) .- Real.(s2.inputs)).^2)

function Base.show(io::IO, s::ExtremaSolution)
    print(io, "(")
    for c in s.inputs
        print(io, "$(c.v), ")
    end
    print(io, ")")
end                                                                
                                                                
struct ExtremaSolutionFactory <: SolutionFactory
    inputs::Vector{Parameter}
end

ExtremaSolutionFactory(range...) = ExtremaSolutionFactory(
    [RangeNormalizedParameter(Pair(range[i], range[i+1])) for i in 1:2:length(range)],
)

create_solution(s::ExtremaSolutionFactory) = ExtremaSolution([init(c) for c in s.inputs])

function propagate_solution(sf::ExtremaSolutionFactory, sl::ExtremaSolution)
    ExtremaSolution([seed(sfc, slp) for (sfc, slp) in zip(sf.inputs, sl.inputs)])
end
