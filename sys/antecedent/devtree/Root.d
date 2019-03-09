#include "devtree/Tree.d"

procedure DevRootBuild (* -- *)
	"antecedent-ebus" DSetName
	"3.0" "version" DAddProperty
	"Ash" "author" DAddProperty
	pointerof ANTEBNS "build" DAddProperty

	BuildTree
end

asm "

ANTEBN === #build

ANTEBNS:
	.ds$ ANTEBN
	.db 0x0

"