﻿;{
; * RegistryHelper.pbi
; Version: 0.0.1
; Author: Herwin Bozet
;
; License: Unlicense (Public Domain)
;}

;- Notes

; No notes currently available.


;- Compiler Directives

EnableExplicit

XIncludeFile "./WinTypes.pbi"

CompilerIf Not #PB_Compiler_OS = #PB_OS_Windows
	CompilerError "Includes is intended to be used on Windows platforms only !"
CompilerEndIf


;- Module Declaration

DeclareModule RegistryHelper
	;{ RegGetValueW Import & loading (Unused due to errors)
	; Does not work on x64, even if the signature used for the library loading is the same...
	; 	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	; 		#ADVAPILIB_PATH$ = "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86\AdvAPI32.Lib"
	; 		#ADVAPILIB_SYMBOL$ = "_RegGetValueW@28"
	; 	CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x64
	; 		#ADVAPILIB_PATH$ = "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\arm64\AdvAPI32.Lib"
	; 		#ADVAPILIB_SYMBOL$ = "RegGetValueW"
	; 	CompilerElse
	; 		CompilerError "Unable to compile for the current architecture !"
	; 	CompilerEndIf
	; 	
	; 	Import #ADVAPILIB_PATH$
	; 		RegGetValueW_.WinTypes::LSTATUS(hkey.WinTypes::HKEY, lpSubKey.WinTypes::LPCWSTR, lpValue.WinTypes::LPCWSTR,
	; 		                                dwFlags.WinTypes::DWORD, pdwType.WinTypes::LPDWORD, pvData.WinTypes::PVOID,
	; 		                                pcbData.WinTypes::LPDWORD) As #ADVAPILIB_SYMBOL$
	; 	EndImport
	
	; Works perfectly fine but requires extra cleaning steps
	; 	Prototype.i _RegGetValueW(hKey.l, lpSubKey.s, lpValue.s, dwFlags.l, *pdwType, *pvData, *pcbData)
	; 	
	; 	Global LibrariIdAdvapi32 = OpenLibrary(#PB_Any, "Advapi32.dll")
	; 	
	; 	If IsLibrary(LibrariIdAdvapi32)
	; 		RegGetValueW = GetFunction(LibrariIdAdvapi32, "RegGetValueW")
	; 	EndIf
	; 	
	; 	If Not RegGetValueW
	; 		ConsoleError("Failed to open Advapi32.dll !")
	; 	EndIf
	;}
	
	; Not used
	CompilerIf Not Defined(HKEY_PERFORMANCE_TEXT, #PB_Constant)
		#HKEY_PERFORMANCE_TEXT = $80000050
	CompilerEndIf
	
	; Not used
	CompilerIf Not Defined(HKEY_PERFORMANCE_NLSTEXT, #PB_Constant)
		#HKEY_PERFORMANCE_NLSTEXT = $80000060
	CompilerEndIf
	
	; https://docs.microsoft.com/en-us/windows/win32/sysinfo/registry-element-size-limits
	#Size_KeyName = 255
	#Size_ValueName = 16383
	#Size_ValueData_Standard = 1048576
	
	; Used to prevent infinite loops
	#Failsafe_MaxValueCount = 65536
	
	Declare.WinTypes::HKEY DetectRootKey(RegistryKey$)
	Declare.s TrimRootKey(RegistryKey$)
	
	Declare.WinTypes::HKEY _OpenReadingKey(RootKey, SubKey$)
	Declare.WinTypes::HKEY OpenReadingKey(SubKey$)
	Declare.b CloseReadingKey(Key.WinTypes::HKEY)
	
	Declare.b _KeyExists(RootKey.WinTypes::HKEY, SubKey$)
	Declare.b KeyExists(SubKey$)
	
	; TODO: Value exists
	
	Declare.i _GetSubKeys(RootKey, SubKey$, List SubKeys.s())
	Declare.i GetSubKeys(SubKey$, List SubKeys.s())
	
	Declare.i _GetKeyValuePairAsLists(RootKey, SubKey$, List ValueNames.s(), List Values.s())
	Declare.i GetKeyValuePairAsLists(SubKey$, List ValueNames.s(), List Values.s())
	
	Declare.i _GetKeyValuePairAsMap(RootKey, SubKey$, Map ValueNamePair.s())
	Declare.i GetKeyValuePairAsMap(SubKey$, Map ValueNamePair.s())
	
	Declare.i _GetKeyValueNames(RootKey, SubKey$, List ValueNames.s())
	Declare.i GetKeyValueNames(SubKey$, List ValueNames.s())
	
	Declare.i _GetKeyValues(RootKey, SubKey$, List Values.s())
	Declare.i GetKeyValues(SubKey$, List Values.s())
EndDeclareModule


;- Module Definition

Module RegistryHelper
	EnableExplicit
	
	Procedure.WinTypes::HKEY DetectRootKey(RegistryKey$)
		Protected KeyRootElement$ = UCase(StringField(RegistryKey$, 1, "\"))
		
		Select KeyRootElement$
			Case "HKEY_CLASSES_ROOT"
				ProcedureReturn #HKEY_CLASSES_ROOT
			Case "HKEY_CURRENT_CONFIG"
				ProcedureReturn #HKEY_CURRENT_CONFIG
			Case "HKEY_CURRENT_USER"
				ProcedureReturn #HKEY_CURRENT_USER
			Case "HKEY_LOCAL_MACHINE"
				ProcedureReturn #HKEY_LOCAL_MACHINE
			Case "HKEY_USERS"
				ProcedureReturn #HKEY_USERS
		EndSelect
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure.s TrimRootKey(RegistryKey$)
		ProcedureReturn Mid(RegistryKey$, FindString(RegistryKey$, "\", 2) + 1)
	EndProcedure
	
	Procedure.WinTypes::HKEY _OpenReadingKey(RootKey, SubKey$)
		Protected RegistryHandle.WinTypes::HKEY = #Null
		
		If RootKey <> #Null
			If RegOpenKeyEx_(RootKey, SubKey$, 0, #KEY_READ, @RegistryHandle) <> #ERROR_SUCCESS
				Debug "Failed to find or open '"+SubKey$+"' !"
			EndIf
		EndIf
		
		ProcedureReturn RegistryHandle
	EndProcedure
	
	Procedure.WinTypes::HKEY OpenReadingKey(SubKey$)
		ProcedureReturn _OpenReadingKey(DetectRootKey(SubKey$), TrimRootKey(SubKey$))
	EndProcedure
	
	Procedure.b CloseReadingKey(Key.WinTypes::HKEY)
		CloseHandle_(Key)
	EndProcedure
	
	Procedure.b _KeyExists(RootKey.WinTypes::HKEY, SubKey$)
		Protected RegistryHandle.WinTypes::HKEY
		
		If RootKey <> #Null
			If RegOpenKeyEx_(RootKey, SubKey$, 0, #KEY_READ, @RegistryHandle) = #ERROR_SUCCESS
				CloseHandle_(RegistryHandle)
				ProcedureReturn #True
			EndIf
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure.b KeyExists(SubKey$)
		ProcedureReturn _KeyExists(DetectRootKey(SubKey$), TrimRootKey(SubKey$))
	EndProcedure
	
	Procedure.i _GetSubKeys(RootKey, SubKey$, List SubKeys.s())
		Protected RegistryHandle.WinTypes::HKEY
		
		If RootKey <> #Null
			Debug "Null 'RootKey' was given !"
			ProcedureReturn -1
		EndIf
		
		If RegOpenKeyEx_(RootKey, SubKey$, 0, #KEY_READ, @RegistryHandle) <> #ERROR_SUCCESS
			Debug "Failed to find or open the '"+SubKey$+"' subkey !"
			ProcedureReturn -1
		EndIf
		
		Protected *KeyStringBuffer = AllocateMemory(#Size_KeyName + 1)
		Protected KeyStringSize.i = #Size_KeyName
		
		If Not *KeyStringBuffer
			DebuggerError("Failed to allocate memory !")
			RegCloseKey_(RegistryHandle)
			ProcedureReturn -1
		EndIf
		
		Protected ReturnedValue.i = 0
		Protected i.i = 0
		
		Repeat
			If i > 0
				KeyStringSize = #Size_KeyName
				FillMemory(*KeyStringBuffer, #Size_KeyName + 1)
			EndIf
			
			ReturnedValue = RegEnumKeyEx_(RegistryHandle, i, *KeyStringBuffer, @KeyStringSize, #Null, #Null, #Null, #Null)
			
			If ReturnedValue = #ERROR_SUCCESS
				AddElement(SubKeys())
				SubKeys() = PeekS(*KeyStringBuffer, #Size_KeyName)
			ElseIf ReturnedValue = #ERROR_MORE_DATA
				Debug "Not enough space error !"
			EndIf
			
			i = i + 1
		Until ReturnedValue = #ERROR_NO_MORE_ITEMS
		
		FreeMemory(*KeyStringBuffer)
		RegCloseKey_(RegistryHandle)
		
		ProcedureReturn ListSize(SubKeys())
	EndProcedure
	
	Procedure.i GetSubKeys(SubKey$, List SubKeys.s())
		ProcedureReturn _GetSubKeys(DetectRootKey(SubKey$), TrimRootKey(SubKey$), SubKeys())
	EndProcedure
	
	Procedure.i _GetKeyValuePairAsLists(RootKey, SubKey$, List ValueNames.s(), List Values.s())
		Protected RegistryHandle.WinTypes::HKEY = _OpenReadingKey(RootKey, SubKey$)
		
		If Not RegistryHandle
			Debug "Failed to open '"+SubKey$+"' !"
			ProcedureReturn -1
		EndIf
		
		Protected *ValueNameBuffer = AllocateMemory(#Size_ValueName+1)
		Protected ValueNameSize.i = #Size_ValueName
			
		If Not *ValueNameBuffer
			DebuggerError("Failed to allocate memory !")
			CloseReadingKey(RegistryHandle)
			ProcedureReturn -1
		EndIf
		
		Protected *ValueDataBuffer = AllocateMemory(#Size_ValueData_Standard)
		Protected ValueDataSize.i = #Size_ValueData_Standard
		
		If Not *ValueDataBuffer
			DebuggerError("Failed to allocate memory !")
			FreeMemory(*ValueNameBuffer)
			CloseReadingKey(RegistryHandle)
			ProcedureReturn -1
		EndIf
		
		Protected i.i
		
		For i=0 To #Failsafe_MaxValueCount
			Protected ReturnedValue.i = 0
			
			If i > 0
				FillMemory(*ValueNameBuffer, #Size_ValueName+1)
				FillMemory(*ValueDataBuffer, #Size_ValueData_Standard)
			EndIf
			
			ValueNameSize = #Size_ValueName
			ValueDataSize = #Size_ValueData_Standard
			ReturnedValue = RegEnumValue_(RegistryHandle, i, *ValueNameBuffer, @ValueNameSize,
			                              #Null, #Null, *ValueDataBuffer, @ValueDataSize)
			
			If ReturnedValue = #ERROR_NO_MORE_ITEMS
				Break
			Else ; Implies #ERROR_SUCCESS or #ERROR_MORE_DATA
				Debug "> "+PeekS(*ValueNameBuffer, #Size_ValueName)+" #> "+PeekS(*ValueDataBuffer, #Size_ValueData_Standard)
				
				AddElement(ValueNames())
				ValueNames() = PeekS(*ValueNameBuffer, #Size_ValueName)
				
				AddElement(Values())
				Values() = PeekS(*ValueDataBuffer, #Size_ValueData_Standard)
				;ComPortDeviceNames(PeekS(*ValueStringBuffer, #Data_Buffer_Size)) = PeekS(*KeyStringBuffer, #Name_Buffer_Size)
			EndIf
		Next
		
		FreeMemory(*ValueDataBuffer)
		FreeMemory(*ValueNameBuffer)
		CloseReadingKey(RegistryHandle)
		ProcedureReturn ListSize(ValueNames())
	EndProcedure
	
	Procedure.i GetKeyValuePairAsLists(SubKey$, List ValueNames.s(), List Values.s())
		ProcedureReturn _GetKeyValuePairAsLists(DetectRootKey(SubKey$), TrimRootKey(SubKey$), ValueNames(), Values())
	EndProcedure
	
	Procedure.i _GetKeyValuePairAsMap(RootKey, SubKey$, Map ValueNamePair.s())
		Protected RegistryHandle.WinTypes::HKEY = _OpenReadingKey(RootKey, SubKey$)
		
		If Not RegistryHandle
			Debug "Failed to open '"+SubKey$+"' !"
			ProcedureReturn -1
		EndIf
		
		Protected *ValueNameBuffer = AllocateMemory(#Size_ValueName+1)
		Protected ValueNameSize.i = #Size_ValueName
			
		If Not *ValueNameBuffer
			DebuggerError("Failed to allocate memory !")
			CloseReadingKey(RegistryHandle)
			ProcedureReturn -1
		EndIf
		
		Protected *ValueDataBuffer = AllocateMemory(#Size_ValueData_Standard)
		Protected ValueDataSize.i = #Size_ValueData_Standard
		
		If Not *ValueDataBuffer
			DebuggerError("Failed to allocate memory !")
			FreeMemory(*ValueNameBuffer)
			CloseReadingKey(RegistryHandle)
			ProcedureReturn -1
		EndIf
		
		Protected i.i
		
		For i=0 To #Failsafe_MaxValueCount
			Protected ReturnedValue.i = 0
			
			If i > 0
				FillMemory(*ValueNameBuffer, #Size_ValueName+1)
				FillMemory(*ValueDataBuffer, #Size_ValueData_Standard)
			EndIf
			
			ValueNameSize = #Size_ValueName
			ValueDataSize = #Size_ValueData_Standard
			ReturnedValue = RegEnumValue_(RegistryHandle, i, *ValueNameBuffer, @ValueNameSize,
			                              #Null, #Null, *ValueDataBuffer, @ValueDataSize)
			
			If ReturnedValue = #ERROR_NO_MORE_ITEMS
				Break
			Else ; Implies #ERROR_SUCCESS or #ERROR_MORE_DATA
				Debug "> "+PeekS(*ValueNameBuffer, #Size_ValueName)+" #> "+PeekS(*ValueDataBuffer, #Size_ValueData_Standard)
				
				ValueNamePair(PeekS(*ValueNameBuffer, #Size_ValueName)) = PeekS(*ValueDataBuffer, #Size_ValueData_Standard)
			EndIf
		Next
		
		FreeMemory(*ValueDataBuffer)
		FreeMemory(*ValueNameBuffer)
		CloseReadingKey(RegistryHandle)
		ProcedureReturn MapSize(ValueNamePair())
	EndProcedure
	
	Procedure.i GetKeyValuePairAsMap(SubKey$, Map ValueNamePair.s())
		ProcedureReturn _GetKeyValuePairAsMap(DetectRootKey(SubKey$), TrimRootKey(SubKey$), ValueNamePair())
	EndProcedure
	
	Procedure.i _GetKeyValueNames(RootKey, SubKey$, List ValueNames.s())
		Protected NewList TemporaryValueData.s()
		Protected ReturnedValue.i
		
		ReturnedValue = _GetKeyValuePairAsLists(RootKey, SubKey$, ValueNames(), TemporaryValueData())
		FreeList(TemporaryValueData())
		
		ProcedureReturn ReturnedValue
	EndProcedure
	
	Procedure.i GetKeyValueNames(SubKey$, List ValueNames.s())
		ProcedureReturn _GetKeyValueNames(DetectRootKey(SubKey$), TrimRootKey(SubKey$), ValueNames())
	EndProcedure
	
	Procedure.i _GetKeyValues(RootKey, SubKey$, List Values.s())
		Protected NewList TemporaryValueNames.s()
		Protected ReturnedValue.i
		
		ReturnedValue = _GetKeyValuePairAsLists(RootKey, SubKey$, TemporaryValueNames(), Values())
		FreeList(TemporaryValueNames())
		
		ProcedureReturn ReturnedValue
	EndProcedure
	
	Procedure.i GetKeyValues(SubKey$, List Values.s())
		ProcedureReturn _GetKeyValues(DetectRootKey(SubKey$), TrimRootKey(SubKey$), Values())
	EndProcedure
EndModule
