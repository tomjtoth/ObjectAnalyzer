Replicate( Str, Count ) { ; By SKAN / CD: 01-July-2017 | goo.gl/U84K7J
	Return StrReplace( Format( "{:0" Count "}", "" ), 0, Str )
}

ObjAn(&obj, verbosity := 0, title := "") { ; https://github.com/tomjtoth/ObjectAnalyzer
/*
TODO:
implement right click menu with:
 - expand /..below/
 - collapse /..below/
 - find in branch

 */
 	text := ""
	if verbosity > 0
		ind := 0

	__pad(diff := 0) {
		if verbosity > 0
			return  "`n" Replicate(A_Tab , ind - 1 + diff)
	}

	__recurse(&o, parent := 0, add_to_TV := true) {
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
						__recurse(&key,, false)
						text .= ", "
					}
					__recurse(&value, (
						(verbosity > 1) && add_to_TV
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
					), add_to_TV)
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
						(verbosity > 1) && add_to_TV
						? tv.add(key, parent, "icon2")
						: ""
					), add_to_TV)
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


	; prepping GUI if needed
	if (verbosity > 1) {
		results := []
		icons := IL_Create(3)
		for i in [2, 69*4+2, 4]
			IL_Add(icons, "shell32.dll", i)
		
		TraySetIcon "shell32.dll", 24
		g := gui("+Resize +MinSize640x480", "Object Analyzer" (
			a_scriptname != "main.ahk"
			? " - " strreplace(a_scriptname, ".ahk")
			: ""
		) (
			title
			? " - " title
			: ""
		))
		TraySetIcon A_AhkPath, 1
		g.setfont("s12")
		g.OnEvent("size", __resize)
		;g.add("text",,"Search")
		chk := g.add("Checkbox",,"RegEx")
		chk.onevent("Click", __checkbox_click)
		;chk.GetPos(,,, &chkH)
		edit := g.add("edit","ym")
		edit.OnEvent("change", __edit_change)
		btn1 := g.add("button", "ym", "Find")
		btn1.OnEvent("Click", __button1_click)
		btn2 := g.add("button", "ym", "↑")
		btn2.Visible := false
		btn2.OnEvent("Click", __button2_click)
		label := g.add("text", "ym w300")
		label.visible := false
		tv := g.add("treeview", "xm w1024 h600 ImageList" icons)
		static last := 0
	}

	__edit_change(*) {
		if btn2.visible
			btn2.visible := false
		if label.Visible
			label.visible := false
		if btn1.value != "Find"
			ControlSetText("Find", btn1)
		last := 0
	}

	__resize(g, minmax, cliW, cliH) {
		btn1.getpos(, &btnY,, &btnH)
		TV.move(,, cliW - 2*g.MarginX, cliH - btnY - btnH - 2*g.marginy)
	}

	__checkbox_click(cc,*) {
		__edit_change()
		cc.GetPos(&x, &y,, &h)
		tooltip((
			cc.Value
			? ""
			: "NOT "
		) "using Regular Expressions", x+10, y+h+10, 10)
		settimer tooltip.bind(,,, 10), -2500
	}


	__traverse_TV(item := 0) {
		loop {
			if item {
				if chk.value
					? TV.GetText(item) ~= edit.Value
					: instr(TV.GetText(item), edit.Value)
						results.push(item)
				if child := TV.GetChild(item)
					__traverse_TV(child)
			}
		} until !(item := tv.GetNext(item))
	}

	__search_TV() {
		if results.length
			results.RemoveAt(1, results.length)
		__traverse_TV()
	}


	__button1_click(cc,*) {
		if (cc.text = "Find")
		&& edit.value {
			try __search_TV()
			catch Error as e {
				MsgBox(e.message, "Failed to search TV")
				return
			}
			ControlSetText("↓", cc)
			btn2.visible := true
			label.visible := true
		}
		if last < results.length
			TV.Modify(results[++last], "vis select")
		ControlSetText(last "/" results.length " results", label)
	}

	__button2_click(*) {
		if last > 1
			TV.Modify(results[--last], "vis select")
		ControlSetText(last "/" results.length " results", label)
	}
	
	; point of entry here
	__recurse(&obj)

	if (verbosity = 1) {
		f := Fileopen(filepath := a_temp "\" a_now "_objan.txt", "w")
		f.write(text)
		f.Close()
		run filepath
	}
	if verbosity > 1
		g.Show
	if verbosity > 2
		winwaitclose g

	return text
}
