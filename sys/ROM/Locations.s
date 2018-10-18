;hw locations
GraphicsFBStart === 0xF4000000
BusStart === 0xFFFC0000
ResetVector === 0xFFFE0000


;0x0 to 0xFFFFF should be untouched by client programs
;in order to expect Antecedent to still function correctly

;system locations
StackTop === 0x1000

InterruptVectorTable === 0x4000
InterruptVectorTableEnd === 0x4400

CharDevTable === 0x5000
BlockDevTable === 0x6000 ;for driver structs

ScratchBuffer === 0x7000

MonitorBuffer === 0x40000
MonitorWordBuffer === 0x40200

KeyboardBuffer === 0x41000

ClientBottom === 0xA0000