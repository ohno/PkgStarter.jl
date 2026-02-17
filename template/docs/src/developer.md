```@meta
CurrentModule = {{{PKG}}}
```

# Developer Guide

This page describes how to contribute to [{{{PKG}}}.jl](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl).

## Contributing

Please open an [issue](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/issues) before starting significant work. The [ColPrac](https://github.com/SciML/ColPrac) guidelines is recommended. 

[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

## Versioning

This project follows [Semantic Versioning](https://semver.org/). When bumping the version, update the version number in:
- [Project.toml](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/Project.toml#L4)
- [CITATION.bib](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/CITATION.bib#5)

## Commands

This section lists typical commands for local development.

### Clone Repository

Clone the repository. Cloning is required only once. If Revise.jl is not installed, run `import Pkg; Pkg.add("Revise")` in the REPL.

```sh
git clone https://github.com/{{{OWNER}}}/{{{PKG}}}.jl.git
cd {{{PKG}}}.jl
```

### Start Development

Start an interactive session with [Revise.jl](https://github.com/timholy/Revise.jl). If Revise.jl is not installed, run `import Pkg; Pkg.add("Revise")` in the REPL.

```sh
julia --startup-file=no -i -E 'using Revise; import Pkg; Pkg.activate(\".\"); using {{{PKG}}}; {{{PKG}}}.hello()'
```

### Add Dependency

Use these commands to add `PkgName.jl` as a dependency. `Pkg.add` updates [Project.toml](https://github.com/{{{OWNER}}}/{{{PKG}}}.jl/blob/main/Project.toml). If dependencies were edited manually, run `Pkg.resolve()` and `Pkg.instantiate()`.

```sh
julia --project=. --startup-file=no -e 'import Pkg; Pkg.add(\"PkgName\")'
julia --project=. --startup-file=no -e 'import Pkg; Pkg.resolve(); Pkg.instantiate()'
```

### Run Tests

Run the local test suite. Run this before pushing commits.

```sh
julia --project=. --startup-file=no -e 'using Pkg; Pkg.test()'
```

### Generate Documentation

Build the documentation locally. Run the first command once to set up the docs environment, and run the second command to rebuild the documentation.

```sh
julia --project=docs --startup-file=no -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate();'
julia --project=docs --startup-file=no -e 'include("docs/make.jl")'
```
