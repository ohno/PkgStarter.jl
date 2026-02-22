```@meta
CurrentModule = {{{PKG}}}
```

# Developer Guide

Open an [issue](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/issues) before starting significant work. The [ColPrac](https://github.com/SciML/ColPrac) guidelines is recommended.

## Local Setup

This procedure is required only once. Install [Revise.jl](https://github.com/timholy/Revise.jl) and [Runic.jl](https://github.com/fredrikekre/Runic.jl), and clone this [repository](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl).

```sh
# Install Tools
julia --startup-file=no -e 'import Pkg; Pkg.add("Revise")'
julia --project=@runic --startup-file=no -e 'using Pkg; Pkg.add("Runic")'

# Clone Repo
git clone https://github.com/{{{OWNER}}}/{{{PKG}}}.jl.git
cd {{{PKG}}}.jl

# Start Session
julia --startup-file=no -i -E 'using Revise; import Pkg; Pkg.activate("."); using {{{PKG}}}' 
```

You're ready to start with the Step 3 of [How to develop a Julia package](https://julialang.org/contribute/developing_package/#step_3_write_code).

https://pkgdocs.julialang.org/v1/creating-packages/

## Development Flow

1. Start an interactive session with [Revise.jl](https://github.com/timholy/Revise.jl).
2. Change codes.
  - DocString https://documenter.juliadocs.org/stable/man/guide/#Adding-Some-Docstrings
  - Use `julia --project=. --startup-file=no -e 'import Pkg; Pkg.add("Something"); Pkg.resolve(); Pkg.instantiate()'` to add `Something.jl` as a dependency. [Project.toml](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/Project.toml) will be updated.
3. Run formatter. This project uses [Runic](https://github.com/fredrikekre/Runic.jl), a code formatter with rules set in stone. Runic have no configuration.
4. Run the local test suite before pushing commits. [Aqua.jl](https://github.com/JuliaTesting/Aqua.jl) and [JET.jl](https://github.com/aviatesk/JET.jl)
5. Build the documentation locally. Run the first command once to set up the docs environment, and run the second command to rebuild the documentation.

```sh
# Start with Revise.jl
cd {{{PKG}}}.jl
julia --startup-file=no -i -E 'using Revise; import Pkg; Pkg.activate("."); using {{{PKG}}}'

# Run Formatter
julia --project=@runic --startup-file=no -e 'using Runic; Runic.main(["--inplace", "src/"])'

# Run Test
julia --project=. --startup-file=no -e 'using Pkg; Pkg.test()'

# Generate Documentation
julia --project=docs --startup-file=no -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate();'
julia --project=docs --startup-file=no -e 'include("docs/make.jl")'
```

## Versioning and Registering (for Maintainers)

This project follows [Semantic Versioning](https://semver.org/). When bumping the version, update the version number in:

- [Project.toml](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/Project.toml#L4)
- [CITATION.bib](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/CITATION.bib#5)

For registering this package to the [General](https://github.com/JuliaRegistries/General) registry, install [Registrator](https://github.com/JuliaRegistries/Registrator.jl?tab=readme-ov-file#install-registrator) and use via the [GitHub App](https://github.com/JuliaRegistries/Registrator.jl?tab=readme-ov-file#via-the-github-app).
