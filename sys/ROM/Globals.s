;console variables
ConsoleX === 0 ;int
ConsoleY === 2 ;int
ConsoleFGColor === 4 ;byte
ConsoleBGColor === 5 ;byte
;gap big enough to fit a long

ConsoleLastX === 10 ;int
ConsoleLastY === 12 ;int

ConsoleWidth === 14 ;byte
ConsoleHeight === 15 ;byte

ConsoleWM === 16 ;byte
ConsoleHM === 17 ;byte

ConsoleBufEnd === 18 ;long

;graphical variables
GraphicsFBEnd === 128 ;long

GraphicsWidth === 132 ;int
GraphicsHeight === 134 ;int

GraphicsBytesPerRow === 136 ;int

;io variables
IOStdOut === 256 ;byte
IOStdIn === 257 ;byte

KeyboardReadPointer === 258 ;byte
KeyboardWritePointer === 259 ;byte

AHDSpinning === 260 ;byte

BlockLastMajor === 262 ;byte

;control variables
ResetReason === 384 ;byte

;memory
TotalMemory === 512 ;long