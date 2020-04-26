#!/usr/bin/julia

module JuliaRegistry

using LibGit2

function init(path)
    repo = try
        LibGit2.GitRepo(path)
    catch
        if ispath(path)
            rm(path, recursive=true)
        end
        LibGit2.clone("git://github.com/JuliaRegistries/General", path)
    end
    LibGit2.fetch(repo)
    LibGit2.merge!(repo)
end

end
