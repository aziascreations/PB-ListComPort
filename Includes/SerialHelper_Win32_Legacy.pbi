
XIncludeFile "./RegistryHelper.pbi"
XIncludeFile "./WinTypes.pbi"

DeclareModule SerialHelper
	Prototype.i _RegGetValueW(hKey.l, lpSubKey.s, lpValue.s, dwFlags.l, *pdwType, *pvData, *pcbData)
	
	Global RegGetValueW._RegGetValueW = #Null
	
	; Returns a positive integer representing the amount of COM port available.
	; Returns -1 is any error occured.
	Declare.i GetComPortDeviceNameMap(Map ComPortDeviceNames.s())
	Declare.i GetComPortList(List ComPortList.s())
	Declare.i GetComPortFriendlyNameList(List ComPortList.s(), Map ComPortFriendlyNames.s(), FixMissing.b = #True)
	Declare Finish()
EndDeclareModule

Module SerialHelper
	EnableExplicit
	
	UseModule WinTypes
	
	Global LibrariIdAdvapi32 = OpenLibrary(#PB_Any, "Advapi32.dll")
	
	If IsLibrary(LibrariIdAdvapi32)
		RegGetValueW = GetFunction(LibrariIdAdvapi32, "RegGetValueW")
	EndIf
	
	If Not RegGetValueW
		ConsoleError("Failed to open Advapi32.dll !")
	EndIf
	
	#Failsafe_Max_COM_Port_Count = 420
	#Name_Buffer_Size = 32767
	#Data_Buffer_Size = 65536
	
	; Returns a positive integer representing the amount of COM port available.
	; Returns -1 is any error occured.
	Procedure.i GetComPortDeviceNameMap(Map ComPortDeviceNames.s())
		ClearMap(ComPortDeviceNames())
		
		CompilerIf #PB_Compiler_OS = #PB_OS_Linux
			CompilerError "GetComPortDeviceNameMap() is not implemented for Linux !"
			ProcedureReturn -1
		CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
			; Preparing the registry
			Protected RegistryHandle.HANDLE
			
			If RegOpenKeyEx_(#HKEY_LOCAL_MACHINE, "HARDWARE\DEVICEMAP\SERIALCOMM", 0, #KEY_READ, @RegistryHandle) <> #ERROR_SUCCESS
				Debug "Failed to find or open the 'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM' key !"
				ProcedureReturn -1
			EndIf
			
			; Allocating the memory for key and value strings (The +1 is for the 0x00 byte)
			Protected *KeyStringBuffer = AllocateMemory(#Name_Buffer_Size+1)
			Protected KeyStringSize.i = #Name_Buffer_Size
			
			If Not *KeyStringBuffer
				DebuggerError("Failed to allocate memory !")
				RegCloseKey_(RegistryHandle)
				ProcedureReturn -1
			EndIf
			
			Protected *ValueStringBuffer = AllocateMemory(#Data_Buffer_Size)
			Protected ValueStringSize.i = #Data_Buffer_Size
			
			If Not *ValueStringBuffer
				DebuggerError("Failed to allocate memory !")
				FreeMemory(*ValueStringBuffer)
				RegCloseKey_(RegistryHandle)
				ProcedureReturn -1
			EndIf
			
			; Going over the entries in "HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM"...
			Protected i.i
			
			For i=0 To #Failsafe_Max_COM_Port_Count
				Protected ReturnedValue.i = 0
				
				If i > 0
					FillMemory(*KeyStringBuffer, #Name_Buffer_Size+1)
					FillMemory(*ValueStringBuffer, #Data_Buffer_Size)
				EndIf
				
				KeyStringSize = #Name_Buffer_Size
				ValueStringSize = #Data_Buffer_Size
				ReturnedValue = RegEnumValue_(RegistryHandle, i, *KeyStringBuffer, @KeyStringSize,
				                              #Null, #Null, *ValueStringBuffer, @ValueStringSize)
				
				If ReturnedValue = #ERROR_NO_MORE_ITEMS
					Debug "> No more items !"
					Break
				Else ; Implies #ERROR_SUCCESS or #ERROR_MORE_DATA
					Debug "> "+PeekS(*ValueStringBuffer, #Data_Buffer_Size)+" #> "+PeekS(*KeyStringBuffer, #Name_Buffer_Size)
					;ComPortDeviceNames(PeekS(*KeyStringBuffer, #Name_Buffer_Size)) = PeekS(*ValueStringBuffer, #Data_Buffer_Size)
					ComPortDeviceNames(PeekS(*ValueStringBuffer, #Data_Buffer_Size)) = PeekS(*KeyStringBuffer, #Name_Buffer_Size)
				EndIf
			Next
			
			; Cleaning up...
			RegCloseKey_(RegistryHandle)
			FreeMemory(*KeyStringBuffer)
			FreeMemory(*ValueStringBuffer)
		CompilerEndIf
		
		ProcedureReturn MapSize(ComPortDeviceNames())
	EndProcedure
	
	; Returns a positive integer representing the amount of COM port available.
	; Returns -1 is any error occured.
	Procedure.i GetComPortList(List ComPortList.s())
		Protected NewMap ComPortDeviceNames.s()
		
		ClearList(ComPortList())
		
		If GetComPortDeviceNameMap(ComPortDeviceNames()) <> -1
			ForEach ComPortDeviceNames()
				AddElement(ComPortList())
				ComPortList() = MapKey(ComPortDeviceNames())
			Next
		EndIf
		
		FreeMap(ComPortDeviceNames())
		
		ProcedureReturn ListSize(ComPortList())
	EndProcedure
	
	Procedure.i GetRegistrySubKeys(RootKey, SubKey.s, List SubKeys.s(), SkipListClear.b = #False)
		Protected RegistryHandle.HANDLE
		
		If Not SkipListClear
			ClearList(SubKeys())
		EndIf
		
		If RegOpenKeyEx_(RootKey, SubKey, 0, #KEY_READ, @RegistryHandle) <> #ERROR_SUCCESS
			Debug "Failed to find or open the '"+SubKey+"' subkey !"
			ProcedureReturn -1
		EndIf
		
		; Allocating the memory for key and value strings (The +1 is for the 0x00 byte)
		Protected *KeyStringBuffer = AllocateMemory(#Name_Buffer_Size+1)
		Protected KeyStringSize.i = #Name_Buffer_Size
		
		If Not *KeyStringBuffer
			DebuggerError("Failed to allocate memory !")
			RegCloseKey_(RegistryHandle)
			ProcedureReturn -1
		EndIf
		
		; Listing the subkeys...
		Protected ReturnedValue.i = 0
		Protected i.i = 0
		
		Repeat
			If i > 0
				KeyStringSize = #Name_Buffer_Size
				FillMemory(*KeyStringBuffer, #Name_Buffer_Size+1)
			EndIf
			
			ReturnedValue = RegEnumKeyEx_(RegistryHandle, i, *KeyStringBuffer, @KeyStringSize, #Null, #Null, #Null, #Null)
			
			If ReturnedValue = #ERROR_SUCCESS
				AddElement(SubKeys())
				SubKeys() = PeekS(*KeyStringBuffer, #Name_Buffer_Size)
			ElseIf ReturnedValue = #ERROR_MORE_DATA
				; Should never happen (Buffer is way bigger than the maximum possible returned value)
				Debug "Not enough space error !"
			EndIf
			
			i = i + 1
		Until ReturnedValue = #ERROR_NO_MORE_ITEMS
		
		; Cleaning up...
		FreeMemory(*KeyStringBuffer)
		RegCloseKey_(RegistryHandle)
		
		ProcedureReturn ListSize(SubKeys())
	EndProcedure
	
	Procedure.i GetComPortFriendlyNameList(List ComPortList.s(), Map ComPortFriendlyNames.s(), FixMissing.b = #True)
		ClearMap(ComPortFriendlyNames())
		
		CompilerIf #PB_Compiler_OS = #PB_OS_Linux
			CompilerError "GetComPortFriendlyNameList() is not implemented for Linux !"
			ProcedureReturn -1
		CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
			; Preparing the registry
			Protected NewList MainSubKeys.s()
			
			If GetRegistrySubKeys(#HKEY_LOCAL_MACHINE, "SYSTEM\ControlSet001\Enum", MainSubKeys()) <> -1
				; Listing the subkeys in the subkeys from "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum"
				Protected NewList SubSubKeys.s()
				ForEach MainSubKeys()
					If MainSubKeys() = "ACPI" Or
					   MainSubKeys() = "ACPI_HAL" Or
					   MainSubKeys() = "HDAUDIO" Or
					   MainSubKeys() = "SCSI" Or
					   MainSubKeys() = "STORAGE" Or
					   MainSubKeys() = "SW" Or
					   MainSubKeys() = "SWD" Or
					   MainSubKeys() = "UEFI"
						Continue
					EndIf
					Protected NewList CurrentSubSubKeys.s()
					If GetRegistrySubKeys(#HKEY_LOCAL_MACHINE, "SYSTEM\ControlSet001\Enum\"+MainSubKeys(), CurrentSubSubKeys()) <> -1
						ForEach CurrentSubSubKeys()
							AddElement(SubSubKeys())
							SubSubKeys() = "SYSTEM\ControlSet001\Enum\"+MainSubKeys()+"\"+CurrentSubSubKeys()
						Next
					EndIf
					FreeList(CurrentSubSubKeys())
				Next
				FreeList(MainSubKeys())
				
				; Doing a second pass due to nesting...
				Protected NewList SubSubSubKeys.s()
				ForEach SubSubKeys()
					Protected NewList CurrentSubSubSubKeys.s()
					If GetRegistrySubKeys(#HKEY_LOCAL_MACHINE, SubSubKeys(), CurrentSubSubSubKeys()) <> -1
						ForEach CurrentSubSubSubKeys()
							AddElement(SubSubSubKeys())
							SubSubSubKeys() = SubSubKeys()+"\"+CurrentSubSubSubKeys()
						Next
					EndIf
					FreeList(CurrentSubSubSubKeys())
				Next
				FreeList(SubSubKeys())
				
				; Extracting all the keys named "FriendlyName"...
				Protected NewList FriendlyNames.s()
				
				ForEach SubSubSubKeys()
					; Preparing the buffer...
					Protected *ValueStringBuffer = AllocateMemory(#Data_Buffer_Size)
					Protected ValueStringSize.i = #Data_Buffer_Size
					
					If Not *ValueStringBuffer
						DebuggerError("Failed to allocate memory !")
						Continue
					EndIf
					
					; Getting the value...
					Protected ReturnedValue.i = 0
					
					If RegGetValueW(#HKEY_LOCAL_MACHINE, SubSubSubKeys(), "FriendlyName",
					                                 $00000002, #Null, *ValueStringBuffer, @ValueStringSize) = #ERROR_SUCCESS
						AddElement(FriendlyNames())
						FriendlyNames() = PeekS(*ValueStringBuffer, #Data_Buffer_Size)
					EndIf
					
					FreeMemory(*ValueStringBuffer)
				Next
				
				FreeList(SubSubSubKeys())
				
				; Filtering the extracted "FriendlyName" keys...
				ForEach(ComPortList())
					Protected HasFoundName.b = #False
					
					ForEach(FriendlyNames())
						If FindString(FriendlyNames(), "("+ComPortList()+")") <> 0
							ComPortFriendlyNames(ComPortList()) = FriendlyNames()
							HasFoundName = #True
							Break
						EndIf
					Next
					
					If Not HasFoundName
						If FixMissing
							ComPortFriendlyNames(ComPortList()) = "No friendly name found ("+ComPortList()+")"
						Else
							ComPortFriendlyNames(ComPortList()) = ""
						EndIf
					EndIf
				Next
				
				FreeList(FriendlyNames())
			Else
				Debug "Failed to get the subkeys in 'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum' !"
				ProcedureReturn -1
			EndIf
		CompilerEndIf
		
		ProcedureReturn MapSize(ComPortFriendlyNames())
	EndProcedure
	
	Procedure Finish()
		If IsLibrary(LibrariIdAdvapi32)
			CloseLibrary(LibrariIdAdvapi32)
		EndIf
	EndProcedure	
EndModule

CompilerIf #PB_Compiler_IsMainFile
	;CompilerWarning "This Include should not be compiled as a standalone program !"
	
	Debug "##### Map procedure #####"
	Global NewMap ComPortDeviceName.s()
	Debug Str(SerialHelper::GetComPortDeviceNameMap(ComPortDeviceName())) + " port(s) found !"
	ForEach ComPortDeviceName()
		Debug "#> "+ComPortDeviceName()
	Next
	FreeMap(ComPortDeviceName())
	Debug ""
	
	Debug "##### List procedure #####"
	Global NewList ComPortsList.s()
	Debug Str(SerialHelper::GetComPortList(ComPortsList())) + " port(s) found !"
	ForEach ComPortsList()
		Debug "#> "+ComPortsList()
	Next
	Debug ""
	
	Debug "##### Friendly names procedure #####"
	Global NewMap ComPortFriendlyNames.s()
	Debug Str(SerialHelper::GetComPortFriendlyNameList(ComPortsList(), ComPortFriendlyNames())) + " port name(s) found !"
	ForEach ComPortFriendlyNames()
		Debug "#> "+MapKey(ComPortFriendlyNames())+" -> "+ComPortFriendlyNames()
	Next
	FreeMap(ComPortFriendlyNames())
	FreeList(ComPortsList())
CompilerEndIf
