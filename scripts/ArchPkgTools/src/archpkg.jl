#!/usr/bin/julia

module ArchPkg

using LibALPM
using Base.Filesystem

function init(workdir)
    root = joinpath(workdir, "archroot")
    dbs = joinpath(workdir, "archdbs")
    mkpath(root)
    mkpath(dbs)
    hdl = LibALPM.Handle(root, dbs)
    LibALPM.set_dbext(hdl, ".files")
    return hdl
end

function ensure_db(hdl::LibALPM.Handle, name, url)
    for db in LibALPM.get_syncdbs(hdl)
        if LibALPM.get_name(db) == name
            return db
        end
    end
    db = LibALPM.register_syncdb(hdl, name,
                                 LibALPM.SigLevel.PACKAGE_OPTIONAL |
                                 LibALPM.SigLevel.DATABASE_OPTIONAL)
    LibALPM.set_servers(db, [url])
    LibALPM.update(db, false)
end

function get_files(db::LibALPM.DB, name)
    pkg = LibALPM.get_pkg(db, name)
    return LibALPM.get_files(pkg)
end

end
