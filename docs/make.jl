using DFA
using Documenter

DocMeta.setdocmeta!(DFA, :DocTestSetup, :(using DFA); recursive=true)

makedocs(;
    modules=[DFA],
    authors="afternone, Alberto Barradas <abcsds@gmail.com>, and contributors",
    sitename="DFA.jl",
    format=Documenter.HTML(;
        canonical="https://abcsds.github.io/DFA.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/abcsds/DFA.jl",
    devbranch="main",
)
