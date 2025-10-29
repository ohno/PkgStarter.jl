using PkgStarter
using Documenter

DocMeta.setdocmeta!(PkgStarter, :DocTestSetup, :(using PkgStarter); recursive=true)

makedocs(;
    modules=[PkgStarter],
    authors="Shuhei Ohno",
    sitename="PkgStarter.jl",
    format=Documenter.HTML(;
        canonical="https://ohno.github.io/PkgStarter.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ohno/PkgStarter.jl",
    devbranch="main",
)
