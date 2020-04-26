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

struct PrefixInfo
    pkgname::String
    repo::String
    remote::String
    conflicts::Vector{String}
    provides::Vector{String}
    replaces::Vector{String}
end

function _load_prefix(info::Dict)
    return PrefixInfo(info["pkgname"], info["repo"], info["remote"],
                      get(info, "conflicts", String[]),
                      get(info, "provides", String[]),
                      get(info, "replaces", String[]))
end

function load_prefixes(repo_dir)
    prefix_info = TOML.parsefile(joinpath(repo_dir, "prefix-info.toml"))
    return Dict{String,PrefixInfo}((prefix=>_load_prefix(info)
                                    for (prefix, info) in prefix_info["prefix"]))
end

end
