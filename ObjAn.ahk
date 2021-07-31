#esc::reload

ObjAn2(obj) {
	txt := ""
	__recurse(o) {
		open := close := e :=""
		if isobject(o) {
			txt .= "{"
			if o.HasProp("__item") {
				switch o.__class {
				case "Map":
					open .= "map("
					close := ")"
					e := o
				case "Array":
					open := "["
					close := "]"
					e := o
				default:
					switch o.__item.__class {
					case "Map":
						open .= "map("
						close := ")"
					case "Array":
						open := "["
						close := "]"
					}	
					; __enum:Array.prototype.__enum is expecting an Array, not an Object
					; assigning base:Array.prototype didn't help
					e := o.__item 
				}
				txt .= "__item:" open
				for k, v in e {
					txt .= a_index > 1 ? "," : ""
					if open = "map(" {
						__recurse(k)
						txt .= ","
					}
					__recurse(v)
				}
				txt .= close (
					ObjOwnPropCount(o)
					? ","
					: ""
				)
			}
			i:=0
			for k, v in o.OwnProps() {
				if k = "__item"
					continue
				txt .= (
					i > 0
					? ","
					: ""
				) k ":"
				__recurse(v)
				i++
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
	a_clipboard := "objan2(" txt ")" ; for testing purposes only
	tooltip "ready to paste"
	settimer tooltip, -1000
	return txt
}

; building my usual kind of structure, maps and array with additional propertis I define later...
test := Map(
	"mapkey1","mapval1",
	"mapkey2",{
		objkey1:"objval1",
		objkey2:[
			1,2,3,4,5
		],
		objkey3:"
		(
			this is a multiline
			string with a ontinuation Section
			and "double quoted" and 'single quoted'
			lines
		)"
	},
	"mapkey3",[
		11,12,13,14,15
	]
)
test.propkey1:=1
test["mapkey2"].propkey2:=2
test["mapkey2"].objkey2.propkey3:=3

; converting the properly built structure into string 1st
objan2(test)

; pasting the clipboard content from 1st run:
objan2({__item:map("mapkey1","mapval1","mapkey2",{objkey1:"objval1",objkey2:{__item:[1,2,3,4,5],propkey3:3},objkey3:"this is a multiline`nstring with a ontinuation Section`nand `"double quoted`" and 'single quoted'`nlines",propkey2:2}),propkey1:1})

; VALIDATION

test2 := {__item:map("mapkey1","mapval1","mapkey2",{objkey1:"objval1",objkey2:{__item:[1,2,3,4,5],propkey3:3},objkey3:"this is a multiline`nstring with a ontinuation Section`nand `"double quoted`" and 'single quoted'`nlines",propkey2:2}),propkey1:1}

if test.propkey1 = test2.propkey1
&& test["mapkey2"].propkey2 = test2["mapkey2"].propkey2
&& test["mapkey2"].objkey2.propkey3 = test2["mapkey2"].objkey2.propkey3
	msgbox "
	(
		some properties are
		the same on both objects
	)", "SUCCESSFUL VALIDATON"
