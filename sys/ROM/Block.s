;block device interface

;the block driver interface consists of
;registering a driver, with a given 8-bit
;"major" number.
;this major number has a structure associated
;with it which contains pointers to interface
;functions. this interface is detailed below

;works in blocks of 4kb

;+-------------------------------------------------------------
;|ReadBlock  | r0 - minor, r1 - block number, r2 - buffer
;+-------------------------------------------------------------
;|WriteBlock | r0 - minor, r1 - block number, r2 - buffer
;+-------------------------------------------------------------

;each individual device has a "minor" number
;associated with it. it is up to the driver to
;maintain internal bookkeeping on every
;individual device.

;a block device is identified with a 16-bit number.
;the least significant 8 bits are the minor number,
;the most significant 8 bits are the major number.

;the outward-facing block I/O interface is
;detailed below

;+-----------------------------------------------------------------------------------------------
;|ReadBlock     | r0 - device num, r1 - block number. outputs: r0 - buffer pointer or error code
;+-----------------------------------------------------------------------------------------------
;|WriteBlock    | r0 - buffer pointer
;+-----------------------------------------------------------------------------------------------
;|ReleaseBuffer | r0 - buffer pointer
;+-----------------------------------------------------------------------------------------------

.struct BlockDriver
	ReadBlock 4
	WriteBlock 4
end-struct

;4103 bytes: kinda an ugly number
.struct BlockBuffer
	Ref 1
	Device 2
	Block 4
	Data 4096
end-struct

;constants
BlockCacheSize === 32

;error codes
BlockNoMem === 1



























