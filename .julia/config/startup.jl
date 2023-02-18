libs = [
    # "Clp",
    "Colors",
    "DataFrames",
    "DataFramesMeta",
    "Distributions",
    "ForwardDiff",
    "GLM",
    "Graphs",
    "GraphPlot",
    "GraphRecipes",
    "HDF5",
    "JuMP",
    "LanguageServer",
    "LaTeXStrings",
    "MetaGraphs",
    "MKL",
    "MultivariateStats",
    "PackageCompiler",
    "PGFPlotsX",
    "PkgTemplates",
    "Plots",
    "PyPlot",
    "RDatasets",
    "Revise",
    "StatsBase",
    "StatsPlots",
    "SpecialFunctions",
    "SymbolServer",
    "Turing"
]

libpath = joinpath(homedir(), ".julia/config/sys_libs.so")
using Pkg
for lib in libs
    if !(lib ∈ keys(Pkg.project().dependencies))
        if isfile(libpath)
            rm(libpath)
        end
    end
end
Pkg.add(libs)

if !isfile(libpath)
    using PackageCompiler
    # create_sysimage(libs, sysimage_path=libpath)
end
