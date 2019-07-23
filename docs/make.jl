using Documenter, PaddyFieldAlgorithm

makedocs(
    modules = [PaddyFieldAlgorithm],
    sitename = "PaddyFieldAlgorithm.jl",
    pages = Any[
        "Home" => "index.md",
        "Solution" => "solution.md",
        "Regression" => "regression.md",
    ],
)

deploydocs(
    repo = "github.com/chopralab/PaddyFieldAlgorithm.jl.git",
    target = "build",
)
