using IORules
using Documenter

DocMeta.setdocmeta!(IORules, :DocTestSetup, :(using IORules); recursive=true)

makedocs(;
    modules=[IORules],
    authors="Anton Oresten <antonoresten@gmail.com> and contributors",
    sitename="IORules.jl",
    format=Documenter.HTML(;
        canonical="https://AntonOresten.github.io/IORules.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/AntonOresten/IORules.jl",
    devbranch="main",
)
