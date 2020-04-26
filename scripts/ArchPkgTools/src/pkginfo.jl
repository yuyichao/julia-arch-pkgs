#!/usr/bin/julia

module JuliaPkg

using DataStructures
using Pkg
using Pkg.TOML
using UUIDs

struct Info
    name::String
    repo::String
    uuid::UUID
    versions::typeof(SortedDict{VersionNumber,String}())
    deps::Vector{Tuple{Pkg.Types.VersionSpec,Vector{String}}}

    function Info(name, registry_dir)
        pkg_dir = joinpath(registry_dir, string(name[1]), name)
        pkg = TOML.parsefile(joinpath(pkg_dir, "Package.toml"))
        repo = pkg["repo"]
        uuid = UUID(pkg["uuid"])
        versions = SortedDict{VersionNumber,String}()
        for (ver, info) in TOML.parsefile(joinpath(pkg_dir, "Versions.toml"))
            versions[VersionNumber(ver)] = info["git-tree-sha1"]
        end
        deps = Tuple{Pkg.Types.VersionSpec,Vector{String}}[]
        for (verstr, verdep) in TOML.parsefile(joinpath(pkg_dir, "Deps.toml"))
            push!(deps, (Pkg.Types.VersionSpec(verstr), collect(keys(verdep))))
        end
        return new(name, repo, uuid, versions, deps)
    end
end

function latest_ver(pkginfo::Info)
    return first(last(pkginfo.versions))
end

function get_version_hash(pkginfo::Info, ver::VersionNumber)
    return pkginfo.versions[ver]
end

function get_deps(pkginfo::Info, ver::VersionNumber)
    res = Set{String}()
    for (verspec, deps) in pkginfo.deps
        ver in verspec || continue
        union!(res, deps)
    end
    return res
end

function get_all_deps(pkgs, registry_dir, builtins)
    if isa(pkgs, String) || isa(pkgs, Info)
        pkgs = [pkgs]
    end
    res = Dict{String,Info}()
    workset = Set{Info}()
    for pkg in pkgs
        if !isa(pkg, Info)
            pkg = Info(pkg, registry_dir)
        end
        push!(workset, pkg)
        res[pkg.name] = pkg
    end
    while !isempty(workset)
        pkg = pop!(workset)
        ver = latest_ver(pkg)
        deps = get_deps(pkg, ver)
        for dep in deps
            if haskey(res, dep) || dep in builtins
                continue
            end
            dep = Info(dep, registry_dir)
            push!(workset, dep)
            res[dep.name] = dep
        end
    end
    if haskey(res, "julia")
        delete!(res, "julia")
    end
    return res
end

end
