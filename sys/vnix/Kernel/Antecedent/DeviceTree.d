struct DeviceTreeNode
	4 Name
	4 Methods
	4 Properties
endstruct

(* DeviceTree methods are called like [ ... node -- ... ] *)
struct DeviceTreeMethod
	4 Name
	4 Func
endstruct

struct DeviceTreeProperty
	4 Name
	4 Value
endstruct

var DevTree 0
var DevCurrent 0

var DevStack 0 (* we can go 64 layers deep *)
var DevStackPtr 0

procedure DevStackPUSH (* v -- *)
	DevStack@ DevStackPtr@ + !
	DevStackPtr@ 4 + DevStackPtr!
end

procedure DevStackPOP (* -- v *)
	DevStackPtr@ 4 - dup DevStackPtr!
	DevStack@ + @
end

procedure DevTreeWalk (* path -- node or 0 *)
	auto path
	path!

	auto cnode
	DevTree@ TreeRoot cnode!

	auto pcomp
	256 Calloc pcomp!

	while (path@ 0 ~=)
		path@ pcomp@ '/' 255 strntok path!

		if (pcomp@ strlen 0 ==)
			cnode@ pcomp@ Free return
		end

		auto tnc
		cnode@ TreeNodeChildren tnc!

		auto n
		tnc@ ListHead n!

		auto nnode
		0 nnode!

		while (n@ 0 ~=)
			auto pnode
			n@ ListNodeValue pnode!

			if (pnode@ TreeNodeValue DeviceTreeNode_Name + @ pcomp@ strcmp)
				pnode@ nnode! break
			end

			n@ ListNode_Next + @ n!
		end

		if (nnode@ 0 ==)
			pcomp@ Free
			0 return
		end

		nnode@ cnode!
	end

	pcomp@ Free

	cnode@
end

procedure DeviceTreeParent (* -- *)
	DevCurrent@@ DevStackPUSH
	DevCurrent@@ TreeNodeParent DevCurrent@!
end

procedure DeviceTreeSelectNode (* node -- *)
	DevCurrent@@ DevStackPUSH
	DevCurrent@!
end

procedure DeviceTreeSelect (* path -- *)
	auto path
	path!

	DevCurrent@@ DevStackPUSH

	path@ DevTreeWalk DevCurrent@!
end

procedure DeviceTreeNNew (* -- node *)
	auto dnode
	DeviceTreeNode_SIZEOF Calloc
	dnode!

	ListCreate dnode@ DeviceTreeNode_Methods + !
	ListCreate dnode@ DeviceTreeNode_Properties + !

	dnode@
end

(* creates a new unnamed DeviceTree node, adds it to the
DeviceTree tree as a child of the current DeviceTree, sets
itself as the new current DeviceTree *)
procedure DeviceTreeNew (* -- *)
	DevCurrent@@ DevStackPUSH

	DeviceTreeNNew DevCurrent@@ DevTree@ TreeInsertChild DevCurrent@!
end

procedure DSetName (* name -- *)
	DevCurrent@@ TreeNodeValue DeviceTreeNode_Name + !
end

procedure DAddMethod (* method name -- *)
	auto name
	name!

	auto method
	method!

	auto mnode
	DeviceTreeMethod_SIZEOF Calloc mnode!

	name@ mnode@ DeviceTreeMethod_Name + !
	method@ mnode@ DeviceTreeMethod_Func + !

	mnode@ DGetMethods ListInsert
end

procedure DAddProperty (* string name -- *)
	auto name
	name!

	auto prop
	prop!

	auto mnode
	DeviceTreeProperty_SIZEOF Calloc mnode!

	name@ mnode@ DeviceTreeProperty_Name + !
	prop@ mnode@ DeviceTreeProperty_Value + !

	mnode@ DGetProperties ListInsert 
end

procedure DGetProperty (* name -- string or 0 *)
	auto name
	name!

	auto plist
	DGetProperties plist!

	auto n
	plist@ ListHead n!

	while (n@ 0 ~=)
		auto pnode
		n@ ListNodeValue
		pnode!

		if (pnode@ DeviceTreeProperty_Name + @ name@ strcmp)
			pnode@ DeviceTreeProperty_Value + @ return
		end

		n@ ListNodeNext n!
	end

	0 return
end

procedure DCallMethod (* ... name -- ... ok? *)
	auto name
	name!

	auto plist
	DGetMethods plist!

	auto n
	plist@ List_Head + @ n!

	while (n@ 0 ~=)
		auto pnode
		n@ ListNodeValue
		pnode!

		if (pnode@ DeviceTreeMethod_Name + @ name@ strcmp)
			pnode@ DeviceTreeMethod_Func + @ Call 1 return
		end

		n@ ListNodeNext n!
	end

	0
end

procedure DeviceTreeExit (* -- *)
	DevStackPOP DevCurrent@!
end

procedure DGetName (* -- name *)
	DevCurrent@@ TreeNodeValue DeviceTreeNode_Name + @
end

procedure DGetMethods (* -- methods *)
	DevCurrent@@ TreeNodeValue DeviceTreeNode_Methods + @
end

procedure DGetProperties (* -- properties *)
	DevCurrent@@ TreeNodeValue DeviceTreeNode_Properties + @
end

procedure DeviceTreeInit (* dcp root -- *)
	DevCurrent! DevTree!

	256 Calloc DevStack!
end