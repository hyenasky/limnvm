;hw locations
GraphicsFBStart === 0xF4000000
BusStart === 0xFFFC0000
ResetVector === 0xFFFE0000

;system locations
StackTop === 0x1000

InterruptVectorTable === 0x4000
InterruptVectorTableEnd === 0x4400

CharDevTable === 0x5000
BlockDevTable === 0x6000 ;for driver functions

ScratchBuffer === 0x7000

BlockDevCache === 0x10000 ;131296 bytes at least, for 32 blocks of cache

MonitorBuffer === 0x40000
MonitorWordBuffer === 0x40200

KeyboardBuffer === 0x41000

ForthStack === 0x50000

ClientBottom === 0xA0000