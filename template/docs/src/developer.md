```@meta
CurrentModule = {{{PKG}}}
```

# Developer Guide

If you are planning significant changes, open an [issue](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/issues) first. The [ColPrac](https://github.com/SciML/ColPrac) guidelines are recommended.

## One-Time Local Setup

Clone the [repository](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl) and install development tools, [Revise.jl](https://github.com/timholy/Revise.jl) and [Runic.jl](https://github.com/fredrikekre/Runic.jl).

```sh
# Clone the repository
git clone https://github.com/{{{OWNER}}}/{{{PKG}}}.jl.git
cd {{{PKG}}}.jl

# Install tools
julia --startup-file=no -e 'import Pkg; Pkg.add("Revise")'
julia --project=@runic --startup-file=no -e 'using Pkg; Pkg.add("Runic")'

# Instantiate dependencies
julia --project=. --startup-file=no -e 'using Pkg; Pkg.instantiate()'
```

## Daily Development Flow

This section describes the typical workflow for making changes to the package.

1. Start an interactive session with [Revise.jl](https://github.com/timholy/Revise.jl).
2. Change the source code.
3. Format the source code with [Runic.jl](https://github.com/fredrikekre/Runic.jl).
4. Run the tests.
5. Build the documentation locally.
6. Submit a pull request (after steps 3–5 succeed).

```sh
# Start
cd {{{PKG}}}.jl
julia --startup-file=no -i -E 'using Revise; import Pkg; Pkg.activate("."); using {{{PKG}}}'

# Format
julia --project=@runic --startup-file=no -e 'using Runic; exit(Runic.main(ARGS))' -- --inplace .

# Run test
julia --project=. --startup-file=no -e 'using Pkg; Pkg.test()'

# Generate documentation
julia --project=docs --startup-file=no -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate();'
julia --project=docs --startup-file=no -e 'include("docs/make.jl")'
```

To change the source code:
- When making new functions or updating docstrings, refer to [Documenter: Adding docstrings](https://documenter.juliadocs.org/stable/man/guide/#Adding-Some-Docstrings).
- If you need a new dependency, use `julia --project=. --startup-file=no -e 'import Pkg; Pkg.add("SomePackage"); Pkg.resolve(); Pkg.instantiate()'`. Replace `SomePackage` with the actual package name.

For Julia package development basics, see:
- [How to develop a Julia package](https://julialang.org/contribute/developing_package/)
- [Pkg: Creating packages](https://pkgdocs.julialang.org/v1/creating-packages/)

## Versioning and Registering (for Maintainers)

This project follows [Semantic Versioning](https://semver.org/). When bumping the version, update the version number in:

- [Project.toml](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/Project.toml#L4)
- [CITATION.bib](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/CITATION.bib#5)

To register this package in the [General](https://github.com/JuliaRegistries/General) registry, install [Registrator](https://github.com/JuliaRegistries/Registrator.jl?tab=readme-ov-file#install-registrator) and use via the [GitHub App](https://github.com/JuliaRegistries/Registrator.jl?tab=readme-ov-file#via-the-github-app).
