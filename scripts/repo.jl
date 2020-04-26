#!/usr/bin/julia

module Repo

using Pkg.TOML

function get_all_pkgs(repo_dir)
    pkg_dir = joinpath(repo_dir, "pkgs")
    pkgs = Set{String}()
    for d in readdir(pkg_dir)
        pkg_path = joinpath(pkg_dir, d, "pkg.toml")
        isfile(pkg_path) || continue
        push!(pkgs, TOML.parsefile(pkg_path)["name"])
    end
    return pkgs
end

end
