using nng
using Documenter

makedocs(;
    modules = [nng],
    authors = "Guillem <guillemborrell@gmail.com> and contributors",
    repo = "https://github.com/guillemborrell/nng.jl/blob/{commit}{path}#L{line}",
    sitename = "nng.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://guillemborrell.github.io/nng.jl",
        assets = String[],
    ),
    pages = ["Home" => "index.md"],
)

deploydocs(; repo = "github.com/guillemborrell/nng.jl")
