;{- Code Header
; ==- Basic Info -================================
;         Name: ComPortHelper.pbi
;      Version: 0.0.2
;       Author: Herwin Bozet
;
; ==- Compatibility -=============================
;  Compiler version: PureBasic 5.70 (x86/x64)
;  Operating system: Windows 10 21H1 (Previous versions untested)
; 
; ==- Links & License -===========================
;  License: Unlicense
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
	;-> Semver Data
	
	#Version_Major = 2
	#Version_Minor = 0
	#Version_Patch = 0
	#Version_Label$ = ""
	#Version$ = "2.0.0";+"-"+#Version_Label$
	
	
	;-> Constants
	
	#RegistryKeyFull_DeviceMap_SerialCom$ = "HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM"
	#RegistryKeyFull_DeviceMap_ParallelPorts$ = "HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\PARALLEL PORTS"
	#RegistryKeyFull_DeviceEnum$ = "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum"
	
	#RegistryValueName_FriendlyName$ = "FriendlyName"
	
	
	;-> Macro Definition
	
	Macro GetComPortAndDeviceNameLists(DeviceNames, ComPortNames)
		RegistryHelper::GetKeyValuePairAsLists(ComPortHelper::#RegistryKeyFull_DeviceMap_SerialCom$, DeviceNames, ComPortNames)
	EndMacro
	
	Macro GetComDeviceNameList(DeviceNames)
		RegistryHelper::GetKeyValueNames(ComPortHelper::#RegistryKeyFull_DeviceMap_SerialCom$, DeviceNames)
	EndMacro
	
	Macro GetComPortList(ComPortNames)
		RegistryHelper::GetKeyValues(ComPortHelper::#RegistryKeyFull_DeviceMap_SerialCom$, ComPortNames)
	EndMacro
	
	Macro GetParallelPortAndDeviceNameLists(DeviceNames, ParallelPortNames)
		RegistryHelper::GetKeyValuePairAsLists(ComPortHelper::#RegistryKeyFull_DeviceMap_ParallelPorts$, DeviceNames, ParallelPortNames)
	EndMacro
	
	Macro GetParallelDeviceNameList(DeviceNames)
		RegistryHelper::GetKeyValueNames(ComPortHelper::#RegistryKeyFull_DeviceMap_ParallelPorts$, DeviceNames)
	EndMacro
	
	Macro GetParallelPortList(ParallelPortNames)
		RegistryHelper::GetKeyValues(ComPortHelper::#RegistryKeyFull_DeviceMap_ParallelPorts$, ParallelPortNames)
	EndMacro
	
	
	;-> Procedure Declaration
	
	Declare.i GetComPortMappedFriendlyName(List ComPortList.s(), Map ComPortFriendlyNames.s(), FixMissing.b = #True)
EndDeclareModule


;- Module Definition

Module ComPortHelper
	;-> Compiler Directives
	
	EnableExplicit
	
	
	;-> Procedure Definition
	
	Procedure.i GetComPortMappedFriendlyName(List ComPortList.s(), Map ComPortFriendlyNames.s(), FixMissing.b = #True)
		If ListSize(ComPortList()) > 0
			Protected NewList RootSubKeyEnum.s()
			
			If RegistryHelper::GetSubKeys(#RegistryKeyFull_DeviceEnum$, RootSubKeyEnum()) = -1
				Debug "Unable to list main subkeys in '"+#RegistryKeyFull_DeviceEnum$+"'"
				FreeList(RootSubKeyEnum())
				ProcedureReturn -1
			EndIf
			
			Protected NewList SubSubKeyEnum.s()
			
			ForEach(RootSubKeyEnum())
				If RootSubKeyEnum() = "ACPI" Or
				   RootSubKeyEnum() = "ACPI_HAL" Or
				   RootSubKeyEnum() = "HDAUDIO" Or
				   RootSubKeyEnum() = "SCSI" Or
				   RootSubKeyEnum() = "STORAGE" Or
				   RootSubKeyEnum() = "SW" Or
				   RootSubKeyEnum() = "SWD" Or
				   RootSubKeyEnum() = "UEFI"
					Continue
				EndIf
				
				If RegistryHelper::GetSubKeys(#RegistryKeyFull_DeviceEnum$+"\"+RootSubKeyEnum(), SubSubKeyEnum(), #True, #True) = -1
					Debug "Unable to list main subkeys in '"+#RegistryKeyFull_DeviceEnum$+"'"
					Continue
				EndIf
			Next
			
			FreeList(RootSubKeyEnum())
			
			If ListSize(SubSubKeyEnum()) = 0
				Debug "No subsub keys found !"
				FreeList(SubSubKeyEnum())
				ProcedureReturn -1
			EndIf
			
			Protected NewList SubSubSubKeyEnum.s()
			
			ForEach(SubSubKeyEnum())
				If RegistryHelper::GetSubKeys(SubSubKeyEnum(), SubSubSubKeyEnum(), #True, #True) = -1
					Debug "Unable to list main subsubkeys in '"+#RegistryKeyFull_DeviceEnum$+"'"
				EndIf
			Next
			
			FreeList(SubSubKeyEnum())
			
			Protected NewList FriendlyNames.s()
			
			ForEach(SubSubSubKeyEnum())
				Protected Value$ = RegistryHelper::GetValue(SubSubSubKeyEnum(), #RegistryValueName_FriendlyName$)
				
				If Value$ <> #Null$
					AddElement(FriendlyNames())
					FriendlyNames() = Value$
				EndIf
			Next
			
			FreeList(SubSubSubKeyEnum())
			
			ForEach(ComPortList())
				Protected HasFoundName.b = #False
				
				ForEach(FriendlyNames())
					If FindString(FriendlyNames(), "("+ComPortList()+")") <> 0
						ComPortFriendlyNames(ComPortList()) = FriendlyNames()
						HasFoundName = #True
						Break
					EndIf
					
					If Not HasFoundName
						If FixMissing
							ComPortFriendlyNames(ComPortList()) = "No friendly name found ("+ComPortList()+")"
						Else
							ComPortFriendlyNames(ComPortList()) = ""
						EndIf
					EndIf
				Next
			Next
			
			FreeList(FriendlyNames())
		EndIf
		
		ProcedureReturn ListSize(ComPortList())
	EndProcedure
EndModule
