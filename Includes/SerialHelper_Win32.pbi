
DeclareModule SerialHelper
	; Returns a positive integer representing the amount of COM port available.
	; Returns -1 is any error occured.
	Declare.i GetComPortList(List ComPortList.s())
	Declare.s FormatComPortName(ComPortName.s)
EndDeclareModule

Module SerialHelper
	XIncludeFile "./WinAPI_Types.pbi"
	
	EnableExplicit
	
	#Failsafe_Max_COM_Port_Count = 420
	#Name_Buffer_Size = 32767
	#Data_Buffer_Size = 65536
	
	; Returns a positive integer representing the amount of COM port available.
	; Returns -1 is any error occured.
	Procedure.i GetComPortList(List ComPortList.s())
		ClearList(ComPortList())
		CompilerIf #PB_Compiler_OS = #PB_OS_Linux
			; List "/dev/tty*"
			CompilerError "GetComPortList() is not implemented for Linux !"
			ProcedureReturn -1
		CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
			Protected RegistryHandle.HANDLE
			
			If RegOpenKeyEx_(#HKEY_LOCAL_MACHINE, "HARDWARE\DEVICEMAP\SERIALCOMM",
			                 0, #KEY_READ, @RegistryHandle) <> #ERROR_SUCCESS
				Debug "Failed to find/open the key !"
				ProcedureReturn -1
			EndIf
			
			Protected *StringBuffer = AllocateMemory(#Name_Buffer_Size+1)
			Protected StringSize.i = #Name_Buffer_Size
			
			If Not *StringBuffer
				DebuggerError("Failed to allocate memory !")
				RegCloseKey_(RegistryHandle)
				ProcedureReturn -1
			EndIf
			
			Protected *DataBuffer = AllocateMemory(#Data_Buffer_Size)
			Protected DataSize.i = #Data_Buffer_Size
			
			If Not *DataBuffer
				DebuggerError("Failed to allocate memory !")
				FreeMemory(*StringBuffer)
				RegCloseKey_(RegistryHandle)
				ProcedureReturn -1
			EndIf
			
			Protected i.i
			
			For i=0 To #Failsafe_Max_COM_Port_Count
				Protected ReturnedValue.i = 0
				
				If i
					FillMemory(*StringBuffer, #Name_Buffer_Size+1)
					FillMemory(*DataBuffer, #Data_Buffer_Size)
				EndIf
				
				StringSize = #Name_Buffer_Size
				DataSize = #Data_Buffer_Size
				ReturnedValue = RegEnumValue_(RegistryHandle, i, *StringBuffer, @StringSize,
				                              #Null, #Null, *DataBuffer, @DataSize)
				
				If ReturnedValue = #ERROR_NO_MORE_ITEMS
					;Debug "> No more items !"
					Break
				Else ; Implies #ERROR_SUCCESS or #ERROR_MORE_DATA
					 ;Debug "> "+PeekS(*StringBuffer, #Name_Buffer_Size) + " #> "+PeekS(*DataBuffer, #Data_Buffer_Size)
					AddElement(ComPortList())
					ComPortList() = PeekS(*DataBuffer, #Data_Buffer_Size)
				EndIf
			Next
			
			RegCloseKey_(RegistryHandle)
			FreeMemory(*StringBuffer)
		CompilerEndIf
		
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
EndModule

CompilerIf #PB_Compiler_IsMainFile
	CompilerWarning "This Include should not be compiled as a standalone program !"
	
	Global NewList ComPorts.s()
	
	Debug Str(SerialHelper::GetComPortList(ComPorts())) + " port(s) found !"
	SortList(ComPorts(), #PB_Sort_Ascending)
	
	ForEach ComPorts()
		Debug "> "+ComPorts()
	Next
	
	FreeList(ComPorts())
CompilerEndIf
