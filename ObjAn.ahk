
ObjAn2(obj) {
	txt := ""
	__recurse(o) {
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
				for k, v in (
					o.Hasownprop("__item")
					? o
					: o
				) {
					txt .= a_index > 1 ? "," : ""
					if open = "map(" {
						__recurse(k)
						txt .= ","
					}
					__recurse(v)
				}
				txt .= close
			}
			for k, v in o.OwnProps() {
				txt .= "," k ":"
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
	}
	__recurse(obj)
	a_clipboard := "msgbox(objan2(" txt "))"
	return txt
}
