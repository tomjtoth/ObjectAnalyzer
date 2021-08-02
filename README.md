# ObjectAnalyzer

Turn native objects into strings, works with AHK-v2.0-beta.1

# verbosity levels
- 0 : unindented one-liner
- 1 : indented with tabs and linefeeds
- 2 : shows in TreeView (keys which are objects themselves don't get added to the TV)

Useful for saving the states of objects to files and loading them later **with restrictions**:
 - obj[x] := y **WORKS**
 - y := obj[x] **WORKS**
 - obj.push(y) **DOES NOT** work
 - obj.count *SHOULD NOT* work (haven't tested though, not interested)
 - obj.other_native_methods_related_to_maps_or_arrays SHOULD not work either
