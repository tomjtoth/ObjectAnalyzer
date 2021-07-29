ObjAn2(obj) {
	txt := "", lvl := 0
	__recurse(o) {
		++lvl
		if isobject(o) {
			txt .= "{"
			if o.HasProp("__item") {
				txt .= "__item:"
				if o.HasProp("count") {
					open .= "map("
					close := ")"
				} else {
					open := "["
					close := "]"
				}
				txt .= open
				if !o.HasMethod("__enum")
					return
				for k, v in o {
					txt .= a_index > 1 ? "," : ""
					if open = "map(" {
						__recurse(k)
						txt .= ","
					}
					__recurse(v)
				}
				txt .= close
			}
			txt .= ObjOwnPropCount(o) ? "," : ""
			for k, v in o.OwnProps() {
				txt .= (
					a_index > 1
					? ","
					: ""
				) k ":"
				__recurse(v)
			}
			txt .= "}"
		} else {
			if isnumber(o)
				txt .= o
			else
				txt .=  "`"" strreplace(strreplace(strreplace(strreplace(o
				, "`n" , "``n")
				, "`r", "``r")
				, "`t", "``t")
				, "`"", "```"")
				. "`""
		}
		--lvl
	}
	__recurse(obj)
	a_clipboard := "msgbox(objan2(" txt "))"
	return txt
}
