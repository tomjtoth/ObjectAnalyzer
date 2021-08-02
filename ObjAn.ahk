ObjAn2(obj, verbosity := 0) { ; https://github.com/tomjtoth/ObjectAnalyzer
	text := ""
	if verbosity > 0
		ind := 0

	__pad(diff := 0) {
		if verbosity > 0
			return  "`n" Replicate(A_Tab , ind - 1 + diff)
	}

	__recurse(&o, parent := 0) {
		if !isset(o)
			return
		if isobject(o) {
			text .= "{ "
			if verbosity > 0
				ind++
			if o.HasProp("__item") {
				if verbosity > 0
					ind++
				opening := closing := enum := ""
				switch o.__class {
				case "Map":
					opening := "map( "
					closing := ")"
					enum := o
				case "Array":
					opening := "[ "
					closing := "]"
					enum := o
				default:
					switch o.__item.__class {
					case "Map":
						opening := "map( "
						closing := ")"
					case "Array":
						opening := "[ "
						closing := "]"
					}
					enum := o.__item
				}
				text .= __pad() "__item: " opening
				for key, value in enum {
					text .= __pad(1)
					if enum.__class = "Map" {
						__recurse(&key)
						text .= ", "
					}
					__recurse(&value, (
						verbosity > 1
						? tv.add("[" (
							isobject(key)
							? "object at " format("0x{:X}", ObjPtr(key))
							: (
								isnumber(key)
								? key
								: "`"" key "`""
							)
						) "]", parent, "icon3")
						: ""
					))
					text .= (
						a_index < (
							enum.__class = "Array"
							? enum.length
							: enum.count
						)
						? ", "
						: ""
					)
				}
				text .= __pad() closing (
					o.HasOwnProp("__item")
					? (
						ObjOwnPropCount(o) -1 > 0
						? ", "
						: ""
					)
					: (
						ObjOwnPropCount(o)
						? ", "
						: ""
					)
				)
			}
			for key, value in o.OwnProps() {
				if key = "__item"
					continue
				text .= __pad(
					o.HasOwnProp("__item")
					? 0
					: 1
				) key ": "
					__recurse(&value, (
						verbosity > 1
						? tv.add(key, parent, "icon2")
						: ""
					))
				text .= (
					a_index < ObjOwnPropCount(o)
					? ", "
					: ""
				)
			}
			if (verbosity > 0)
			&& o.HasProp("__item")
				ind--
			text .= __pad() "}"
			if verbosity > 0
				ind--
		} else {
			if isnumber(o)
				text .= append := o
			else
				text .= append := "`"" strreplace(strreplace(strreplace(strreplace(o
				, "`n" , "``n")
				, "`r", "``r")
				, "`t", "``t")
				, "`"", "```"")
				. "`""
			if verbosity > 1
				if parent
					tv.modify(parent, (
						instr(parent_text := tv.GetText(parent), "[")
						? "icon1"
						: ""
					), parent_text ": " append)
		}
	}

	__resize(g, minmax, cliW, cliH) {
		tv.move(,, cliW - 2* g.MarginX, cliH - 2*g.marginy)
	}

	; prepping GUI if needed
	if (verbosity > 1) {
		icons := IL_Create(3)
		for i in [2, 69*4+2, 4]
			IL_Add(icons, "shell32.dll", i)
		g := gui("+Resize +MinSize640x480", "Object Analyzer" (
			a_scriptname != "main.ahk"
			? " - " strreplace(a_scriptname, ".ahk")
			: ""
		))
		g.setfont("s12")
		g.OnEvent("size", __resize)
		tv := g.add("treeview","w1024 h600 ImageList" icons)
	}

	; starting to work here
	__recurse(&obj)
	if verbosity = 2
		g.Show

	if (verbosity = 1) { ; debugging
		f := Fileopen(filepath := a_temp "\" a_now "_objan.txt", "w")
		f.write(text)
		f.Close()
		run filepath
	}
	return text
}
