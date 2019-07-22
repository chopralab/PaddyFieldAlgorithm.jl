import Statistics
import StatsBase

export optimize_function

fitness_function(x, y) = sum( (x .- y).^2 )

function find_neighbors(seeds::Vector{T}, r::Real; quantile = 0.75, quantile_step = 0.05) where T <: Solution

    # Calculate the distance between all seeds
    distance_matrix = Matrix{Float64}(undef, length(seeds), length(seeds))
    all_distances = Vector{Float64}()
    for i in 1:length(seeds)
        distance_matrix[i, i] = typemax(Float64)
        for j in (i+1):length(seeds)
            dist = distance(seeds[i], seeds[j])
            distance_matrix[i, j] = dist
            distance_matrix[j, i] = dist
            append!(all_distances, [dist])
        end
    end

    # Calculate the number of neighbors given the seed distances
    is_neighbor = distance_matrix .< r
    while sum(is_neighbor) == 0
        if quantile < 0.05
            println("WARNING: No cross pollination! Setting neighbors to 1")
            return repeat([1], length(seeds))
        end

        quantile_value = Statistics.quantile(all_distances, quantile)
        is_neighbor = distance_matrix .< quantile_value
        quantile = quantile - quantile_step
    end

    [sum(is_neighbor[:, i]) for i in 1:length(seeds)]
end

function pollinate(neighbors::Vector{Int}, fitness::Vector{Float64}) where T <: Solution
    n_max = maximum(neighbors)
    scaling = exp.(neighbors ./ n_max .- 1)
    scaling .* fitness
end

function sow_field(fitness::Vector{Float64}; yt = 10, Qmax = 50) where T <: Solution
    max_fitness = maximum(fitness)
    ranked_fitness = StatsBase.denserank(fitness, rev = true)


    yt_loc = findnext(x -> x == yt, ranked_fitness, 1)
    while yt_loc == nothing
        yt -= 1
        yt_loc = findnext(x -> x == yt, ranked_fitness, 1)
    end
    yt_val = fitness[yt_loc]

    selected_fitness_values = [findnext(x -> x == i, ranked_fitness, 1) for i in 1:yt]
    sown = [Qmax * (fitness[i] - yt_val) / (max_fitness - yt_val) for i in selected_fitness_values]

    (sown, selected_fitness_values)
end

function propagate(sf::T, seeds::Vector{U}, sown_idx::Vector{Int}, propagate_count::Vector{Int}) where {T <: SolutionFactory, U <: Solution}
    new_seeds = Vector{U}()
    for (idx,count) in zip(sown_idx, propagate_count)
        for _ in 1:count
            append!(new_seeds, [propagate_solution(sf, seeds[idx])])
        end
    end
    new_seeds
end

function optimize_function(sf::T, x::Vector{Float64}, y::Vector{Float64}; starting_seeds = 50, r = 0.7, yt = 10, Qmax = 50, iterations = 15) where T <: SolutionFactory

    seeds = [create_solution(sf) for _ in 1:starting_seeds]
    s_fitness = [fitness(s, x, y) for s in seeds]

    for _ in 1:iterations
        sown, sown_idx = sow_field(s_fitness; yt = yt, Qmax = Qmax)

        if length(sown) == 1
            return seeds[1], s_fitness[1]
        end

        neighbors = find_neighbors(seeds[sown_idx], r)
        seeds_to_propagate = Int.(round.(pollinate(neighbors, sown)))

        seeds = propagate(sf, seeds, sown_idx, seeds_to_propagate)
        s_fitness = [fitness(seed, x, y) for seed in seeds]
    end

    best_seed = findmax(s_fitness)
    seeds[best_seed[2]], best_seed[1]
end
