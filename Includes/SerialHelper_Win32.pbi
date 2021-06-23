
DeclareModule SerialHelper
	; Returns a positive integer representing the amount of COM port available.
	; Returns -1 is any error occured.
	Declare.i GetComPortDeviceNameMap(Map ComPortDeviceNames.s())
	Declare.i GetComPortList(List ComPortList.s())
	Declare.s FormatComPortName(ComPortName.s)
	Declare.i GetComPortFriendlyNameList(List ComPortList.s(), List ComPortFriendlyNameList.s())
EndDeclareModule

Module SerialHelper
	XIncludeFile "./WinAPI_Types.pbi"
	
	EnableExplicit
	
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
			
			If RegOpenKeyEx_(#HKEY_LOCAL_MACHINE, "HARDWARE\DEVICEMAP\SERIALCOMM",
			                 0, #KEY_READ, @RegistryHandle) <> #ERROR_SUCCESS
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
					Debug "> "+PeekS(*KeyStringBuffer, #Name_Buffer_Size) + " #> "+PeekS(*ValueStringBuffer, #Data_Buffer_Size)
					ComPortDeviceNames(PeekS(*KeyStringBuffer, #Name_Buffer_Size)) = PeekS(*ValueStringBuffer, #Data_Buffer_Size)
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
				ComPortList() = ComPortDeviceNames()
			Next
		EndIf
		
		FreeMap(ComPortDeviceNames())
		
		ProcedureReturn ListSize(ComPortList())
	EndProcedure
	
	Procedure.s FormatComPortName(ComPortName.s)
		CompilerIf #PB_Compiler_OS = #PB_OS_Linux
			ProcedureReturn "/dev/"+ComPortName
		CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
			ProcedureReturn UCase(ComPortName)
		CompilerElse
			ProcedureReturn ComPortName
		CompilerEndIf
	EndProcedure
	
	Procedure.i GetComPortFriendlyNameList(List ComPortList.s(), List ComPortFriendlyNameList.s())
		ClearList(ComPortFriendlyNameList())
		
		CompilerIf #PB_Compiler_OS = #PB_OS_Linux
			CompilerError "GetComPortFriendlyNameList() is not implemented for Linux !"
			ProcedureReturn -1
		CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
			
		CompilerEndIf
		
		ProcedureReturn ListSize(ComPortFriendlyNameList())
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
	
	Debug "##### List procedure #####"
	Global NewList ComPorts.s()
	Debug Str(SerialHelper::GetComPortList(ComPorts())) + " port(s) found !"
	ForEach ComPorts()
		Debug "#> "+ComPorts()
	Next
	FreeList(ComPorts())
	
CompilerEndIf
