asm preamble "

.include llfw/ROMHeader.s
.include llfw/Reset.s
.include llfw/POST.s
.include llfw/Serial.s
.include llfw/Error.s
.include llfw/Kinnow2.s

AntecedentBase:
.org 0x2000

"