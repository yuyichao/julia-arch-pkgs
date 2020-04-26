#!/usr/bin/julia

module Repo

using ..Utils

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

expand_remote_url(url, repo) =
    Utils.expand_string(url, Dict("repo"=>repo, "arch"=>string(Sys.ARCH)))

function expand_mirrorlist(repo)
    open("/etc/pacman.d/mirrorlist") do fd
        for line in eachline(fd)
            isempty(line) && continue
            line[1] == '#' && continue
            line = strip(line)
            m = match(r"^ *Server *= *([^ ]*)", line)
            m === nothing && continue
            return expand_remote_url((m::RegexMatch).captures[1], repo)
        end
        @warn("Cannot find default server, use mirrors.kernel.org instead")
        return "http://mirrors.kernel.org/archlinux/$repo/os/$(Sys.ARCH)"
    end
end

function expand_remote(remote, repo)
    if remote == "mirrorlist"
        return expand_mirrorlist(repo)
    end
    return expand_remote_url(remote, repo)
end

function _load_prefix(info::Dict)
    repo = info["repo"]
    return PrefixInfo(info["pkgname"], repo, expand_remote(info["remote"], repo),
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
