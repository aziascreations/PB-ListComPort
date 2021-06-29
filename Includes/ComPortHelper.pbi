;{
; * ComPortHelper.pbi
; Version: 0.0.1
; Author: Herwin Bozet
;
; License: Unlicense (Public Domain)
;}

;- Notes

; No notes currently available.


;- Compiler Directives

EnableExplicit

XIncludeFile "./RegistryHelper.pbi"

CompilerIf Not #PB_Compiler_OS = #PB_OS_Windows
	CompilerError "Includes is intended to be used on Windows platforms only !"
CompilerEndIf


;- Module Declaration

DeclareModule ComPortHelper
	Declare.i GetComPortAndDeviceNameLists(List DeviceNames.s(), List ComPortNames.s())
EndDeclareModule


;- Module Definition

Module ComPortHelper
	Procedure.i GetComPortAndDeviceNameLists(List DeviceNames.s(), List ComPortNames.s())
		ProcedureReturn	RegistryHelper::GetKeyValuePairAsLists("HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM", DeviceNames(), ComPortNames())
	EndProcedure
EndModule
