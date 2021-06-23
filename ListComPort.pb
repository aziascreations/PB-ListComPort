;{
; * Arguments.pbi
; Version: 1.0.0
; Author: Herwin Bozet
; 
; A basic arguments parser.
;
; License: Unlicense (Public Domain)
;}

; TODO: #Tab$ and CSV formatted outputs


;- Compiler Directives

EnableExplicit

CompilerIf #PB_Compiler_ExecutableFormat <> #PB_Compiler_Console
	CompilerError("this program need to be compiled as a console application !")
CompilerEndIf


;- Constants

#Sort_Order_Descending = -1
#Sort_Order_None = 0
#Sort_Order_Ascending = 1


;- Code

If Not OpenConsole("lscom")
	; TODO: Play Windows error bell sound
	MessageRequester("Fatal error !", "Failed to open the console !",
	                 #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
	End 1
EndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	XIncludeFile "./Includes/SerialHelper_Win32.pbi"
	
	If Not SerialHelper::RegGetValueW
		ConsoleError("Cannot continue without being able to use RegGetValueW() !")
		SerialHelper::Finish()
		End 2
	EndIf
CompilerElse
	CompilerError "Non-windows platforms are not supported !"
CompilerEndIf

XIncludeFile "./Includes/Arguments.pbi"


;-> Preparing arguments

Define ShouldPrintRawNames.b = #True
Define ShouldPrintDeviceNames.b = #False
Define ShouldPrintFriendlyNames.b = #False
Define SortingOrder.b = #Sort_Order_None

If Arguments::Init()
	Define HasRegisteredArgumentsCorrectly.b = #True
	
	Define *NameAllOption.Arguments::Option = Arguments::CreateOption('a', "show-all", "Display the complete port's name (Equal to -dfn)")
	If Not Arguments::RegisterOption(*NameAllOption)
		ConsoleError("Failed to register *NameAllOption !")
		Arguments::FreeOption(*NameAllOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	Define *NameDeviceOption.Arguments::Option = Arguments::CreateOption('d', "show-device", "Displays the port's device name")
	If Not Arguments::RegisterOption(*NameDeviceOption)
		ConsoleError("Failed to register *NameDeviceOption !")
		Arguments::FreeOption(*NameDeviceOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	Define *NameFriendlyOption.Arguments::Option = Arguments::CreateOption('f', "show-friendly", "Displays the port's friendly name")
	If Not Arguments::RegisterOption(*NameFriendlyOption)
		ConsoleError("Failed to register *NameFriendlyOption !")
		Arguments::FreeOption(*NameFriendlyOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	Define *HelpOption.Arguments::Option = Arguments::CreateOption('h', "help", "Display the help text")
	If Not Arguments::RegisterOption(*HelpOption)
		ConsoleError("Failed to register *HelpOption !")
		Arguments::FreeOption(*HelpOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	Define *NameRawOption.Arguments::Option = Arguments::CreateOption('n', "show-name-raw", "Displays the port's raw name (See info section)")
	If Not Arguments::RegisterOption(*NameRawOption)
		ConsoleError("Failed to register *NameRawOption !")
		Arguments::FreeOption(*NameRawOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	Define *SortAscOption.Arguments::Option = Arguments::CreateOption('s', "sort", "Sorts the port based on their raw names in an ascending order")
	If Not Arguments::RegisterOption(*SortAscOption)
		ConsoleError("Failed to register *SortAscOption !")
		Arguments::FreeOption(*SortAscOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	Define *SortDescOption.Arguments::Option = Arguments::CreateOption('S', "sort-reverse", "Sorts the port based on their raw names in a descending order")
	If Not Arguments::RegisterOption(*SortDescOption)
		ConsoleError("Failed to register *SortDescOption !")
		Arguments::FreeOption(*SortDescOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	If HasRegisteredArgumentsCorrectly
		If Not Arguments::ParseArguments(0, CountProgramParameters())
			If *HelpOption\WasUsed
				PrintN("lscom.exe [-a|--show-all] [-d|--show-device] [-f|--show-friendly] [-h|--help] [-n|--show-name-raw] [-s|--sort] [-S|--sort-reverse]")
				PrintN("")
				PrintN("Arguments:")
				PrintN("-a, --show-all       Display the complete port's name (Equal to '-dfn')")
				PrintN("-d, --show-device    Displays the port's device name")
				PrintN("-f, --show-friendly  Displays the port's friendly name")
				PrintN("-h, --help           Display the help text")
				; Use: HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\COM Name Arbiter\Devices
				;PrintN("-H, --history        Display ??? (Ignores -d, -f & -n )")
				PrintN("-n, --show-name-raw  Displays the port's raw name (See info section)")
				PrintN("-s, --sort           Sorts the port based on their raw names in an ascending order")
				PrintN("-S, --sort-reverse   Sorts the port based on their raw names in a descending order")
				PrintN("")
				PrintN("Remarks:")
				PrintN(" * If '-d' or '-f' is used, the raw name will not be shown unless '-n' is used.")
				PrintN(" * By default, the order the ports are shown in SHOULD be the [plug-in time] order from Windows' registry.")
				PrintN(" * Searching for the friendly names can be a time consuming task !")
				PrintN(" * Raw name simply refers to a port name (e.g.: COM1, COM2, ...)")
				PrintN(" * Device name refers to a port device path (e.g.: \Device\Serial1, ...)")
				PrintN(" * Friendly name refers to a port name as seen in the device manager (e.g.: Communications Port, USB-SERIAL CH340, )")
				PrintN("")
				PrintN("Formatting:")
				PrintN(" * No argument:")
				PrintN("   > $RawName")
				PrintN("     > COM1")
				PrintN(" * '-d' or '-f' ")
				PrintN("   > $DeviceName")
				PrintN("     > \Device\Serial1")
				PrintN("   > $FriendlyName")
				PrintN("     > Communications Port")
				PrintN(" * '-d' and '-f' ")
				PrintN("   > $FriendlyName [$DeviceName]")
				PrintN("     > Communications Port [\Device\Serial1]")
				PrintN(" * '-n' and '-d'")
				PrintN("   > $RawName [$DeviceName]")
				PrintN("     > COM1 [\Device\Serial1]")
				PrintN(" * '-n' and '-f'")
				PrintN("   > $RawName - $FriendlyName")
				PrintN("     > COM1 - Communications Port")
				PrintN(" * '-n' and '-d' and '-f'")
				PrintN("   > $RawName - $FriendlyName [$DeviceName]")
				PrintN("     > COM1 - Communications Port [\Device\Serial1]")
				SerialHelper::Finish()
				End 0
			EndIf
			
			If *NameDeviceOption\WasUsed
				ShouldPrintRawNames = #False
				ShouldPrintDeviceNames = #True
			EndIf
			
			If *NameFriendlyOption\WasUsed
				ShouldPrintRawNames = #False
				ShouldPrintFriendlyNames = #True
			EndIf
			
			If *NameRawOption\WasUsed
				ShouldPrintRawNames = #True
			EndIf
			
			If *NameAllOption\WasUsed
				ShouldPrintDeviceNames = #True
				ShouldPrintFriendlyNames = #True
				ShouldPrintRawNames = #True
			EndIf
			
			If *SortAscOption\WasUsed
				SortingOrder = #Sort_Order_Ascending
			EndIf
			
			If *SortDescOption\WasUsed
				SortingOrder = #Sort_Order_Descending
			EndIf
		Else
			ConsoleError("Failed to parse arguments !")
		EndIf
	Else
		ConsoleError("Failed to register one or more agrument, not parsing arguments...")
	EndIf
	
	; Clearing the memory for the argument parser...
	Arguments::Finish()
Else
	ConsoleError("Failed to initialize the internal argument parser, ignoring them and printing the raw names...")
EndIf


;-> Listing ports

Global IsDoingFine.b = #True
Global NewMap ComPortDeviceNames.s()
Global NewList ComPortRawNames.s()
Global NewMap ComPortFriendlyNames.s() ; May not be used depending on the options used.

If SerialHelper::GetComPortDeviceNameMap(ComPortDeviceNames()) <> -1
	ForEach ComPortDeviceNames()
		AddElement(ComPortRawNames())
		ComPortRawNames() = MapKey(ComPortDeviceNames())
	Next
	
	If ShouldPrintFriendlyNames
		If SerialHelper::GetComPortFriendlyNameList(ComPortRawNames(), ComPortFriendlyNames(), #True) = -1
			ConsoleError("Failed to list the friendly names !")
			IsDoingFine = #False
		EndIf
	EndIf
Else
	ConsoleError("Failed to list the COM ports !")
	IsDoingFine = #False
EndIf

If IsDoingFine
	If SortingOrder = #Sort_Order_Ascending
		SortList(ComPortRawNames(), #PB_Sort_Ascending | #PB_Sort_NoCase)
	EndIf
	
	If SortingOrder = #Sort_Order_Descending
		SortList(ComPortRawNames(), #PB_Sort_Descending | #PB_Sort_NoCase)
	EndIf
	
	ForEach ComPortRawNames()
		If ShouldPrintRawNames
			Print(ComPortRawNames())
			
			If ShouldPrintFriendlyNames
				Print(" - "+ComPortFriendlyNames(ComPortRawNames()))
			EndIf
			
			If ShouldPrintDeviceNames
				PrintN(" ["+ComPortDeviceNames(ComPortRawNames())+"]")
			Else
				Print(#CRLF$)
			EndIf
		Else
			If ShouldPrintFriendlyNames
				Print(ComPortFriendlyNames(ComPortRawNames()))
				If ShouldPrintDeviceNames
					PrintN(" ["+ComPortDeviceNames(ComPortRawNames())+"]")
				Else
					Print(#CRLF$)
				EndIf
			Else
				PrintN(ComPortDeviceNames(ComPortRawNames()))
			EndIf
		EndIf
	Next
EndIf

; Cleaning...
FreeMap(ComPortDeviceNames())
FreeList(ComPortRawNames())
FreeMap(ComPortFriendlyNames())

SerialHelper::Finish()
End 0
