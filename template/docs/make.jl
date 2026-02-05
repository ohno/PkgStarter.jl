using {{{PKG}}}
using Documenter

DocMeta.setdocmeta!({{{PKG}}}, :DocTestSetup, :(using {{{PKG}}}); recursive=true)

makedocs(;
    modules = [{{{PKG}}}],
    authors = "{{{AUTHORS}}}",
    sitename = "{{{PKG}}}.jl",
    format = Documenter.HTML(;
        canonical = "https://{{{OWNER}}}.github.io/{{{PKG}}}.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo = "github.com/{{{OWNER}}}/{{{PKG}}}.jl",
    devbranch = "main",
)
