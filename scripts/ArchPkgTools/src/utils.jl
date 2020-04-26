#!/usr/bin/julia

module Utils

isname(c) = 'a' <= c <= 'z' || 'A' <= c <= 'Z' || '0' <= c <= '9' || c == '_'

function expand_string(template, context)
    segments = split(template, "\$")
    res = String(segments[1])
    for i in 2:length(segments)
        seg = segments[i]
        m = match(r"^(?|\{([_a-zA-Z][_a-zA-Z0-9]*)\}|([_a-zA-Z][_a-zA-Z0-9]*))(.*)", seg)
        if m === nothing
            throw(ArgumentError("Invalid variable syntax in $template"))
        end
        varname = m[1]
        if !haskey(context, varname)
            throw(ArgumentError("Unknown variable reference `$(varname)` in $template"))
        end
        res = res * context[varname] * m[2]
    end
    return res
end

end
