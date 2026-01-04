# PkgStarter

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ohno.github.io/PkgStarter.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ohno.github.io/PkgStarter.jl/dev/)
[![Build Status](https://github.com/ohno/PkgStarter.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ohno/PkgStarter.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/ohno/PkgStarter.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ohno/PkgStarter.jl)

## Documentation

See https://ohno.github.io/PkgStarter.jl.

## Citation

See [`CITATION.bib`](CITATION.bib) for the relevant reference(s).

## Developer's Guide

```
julia -i -E 'using Revise; import Pkg; Pkg.activate("."); using PkgStarter; PkgStarter.hello()'
```

```
julia --project=. -e 'import Pkg; Pkg.update()'
julia --project=. -e 'import Pkg; Pkg.resolve()'
julia --project=. -e 'import Pkg; Pkg.instantiate()'
```