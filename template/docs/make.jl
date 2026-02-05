using template
using Documenter

DocMeta.setdocmeta!(template, :DocTestSetup, :(using template); recursive=true)

makedocs(;
    modules=[template],
    authors="AUTHOR1, AUTHOR2",
    sitename="template.jl",
    format=Documenter.HTML(;
        canonical="https://OWNER_NAME.github.io/template.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/OWNER_NAME/template.jl",
    devbranch="main",
)
