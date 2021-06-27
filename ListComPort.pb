;{
; * Arguments.pbi
; Version: 1.1.0
; Author: Herwin Bozet
; 
; A basic arguments parser.
;
; License: Unlicense (Public Domain)
;}

; TODO: CSV formatted outputs


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


;-> Preparing variables & arguments

Global ExitCode.i = 0

Define ShouldPrintRawNames.b = #True
Define ShouldPrintDeviceNames.b = #False
Define ShouldPrintFriendlyNames.b = #False
Define SortingOrder.b = #Sort_Order_None
Define PaddingString$ = #Null$

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
	
	Define *DividerCharOption.Arguments::Option = Arguments::CreateOption('D', "divider", "Use the first character of the given string as a separator", Arguments::#Option_HasValue)
	If Not Arguments::RegisterOption(*DividerCharOption)
		ConsoleError("Failed to register *DividerCharOption !")
		Arguments::FreeOption(*DividerCharOption)
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
	
	Define *NameRawOption.Arguments::Option = Arguments::CreateOption('n', "show-name-raw", "Displays the port's raw name (See remarks section)")
	If Not Arguments::RegisterOption(*NameRawOption)
		ConsoleError("Failed to register *NameRawOption !")
		Arguments::FreeOption(*NameRawOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	; Maybe name it pretty printing :/
	;Define *NameNoPaddingRawOption.Arguments::Option = Arguments::CreateOption('P', "no-padding", "Disable the automatic padding after the raw name")
	;If Not Arguments::RegisterOption(*NameNoPaddingRawOption)
	;	ConsoleError("Failed to register *NameNoPaddingRawOption !")
	;	Arguments::FreeOption(*NameNoPaddingRawOption)
	;	HasRegisteredArgumentsCorrectly = #False
	;EndIf
	
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
	
	Define *NameTabPaddingOption.Arguments::Option = Arguments::CreateOption('t', "tab-padding", "Use tabs for padding between the types of names (Overrides -D)")
	If Not Arguments::RegisterOption(*NameTabPaddingOption)
		ConsoleError("Failed to register *NameTabPaddingOption !")
		Arguments::FreeOption(*NameTabPaddingOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	If HasRegisteredArgumentsCorrectly
		If Not Arguments::ParseArguments(0, CountProgramParameters())
			If *HelpOption\WasUsed
				PrintN("lscom.exe [-a|--show-all] [-d|--show-device] [-D <str>|--divider <str>] [-f|--show-friendly]")
				PrintN("          [-h|--help] [-n|--show-name-raw] [-s|--sort] [-S|--sort-reverse] [-t|--tab-padding]")
				PrintN("")
				PrintN("Launch arguments:")
				PrintN("-a, --show-all             Display the complete port's name (Equal to '-dfn')")
				PrintN("-d, --show-device          Displays the port's device name")
				PrintN("-D <str>, --divider <str>  Uses the given string or char as a separator (Can be empty string !)")
				PrintN("-f, --show-friendly        Displays the port's friendly name")
				PrintN("-h, --help                 Display the help text")
				; Use: HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\COM Name Arbiter\Devices
				;PrintN("-H, --history        Display ??? (Ignores -d, -f & -n )")
				PrintN("-n, --show-name-raw        Displays the port's raw name (See remarks section)")
				;PrintN("-P, --no-padding     Disable the automatic padding after the raw name")
				PrintN("-s, --sort                 Sorts the port based on their raw names in an ascending order")
				PrintN("-S, --sort-reverse         Sorts the port based on their raw names in a descending order")
				PrintN("-t, --tab-padding          Use tabs for padding between the types of names (Overrides -D)")
				PrintN("")
				PrintN("Remarks:")
				PrintN(" * If '-d' or '-f' is used, the raw name will not be shown unless '-n' is used.")
				PrintN(" * By default, the order the ports are shown in SHOULD be the [plug-in time] order from Windows' registry.")
				PrintN(" * Searching for the friendly names can be a time consuming task !")
				PrintN(" * When -D or -t are used, the separator ' - ' between the raw and friendly name is set to the given separator.")
				PrintN(" * Raw name simply refers to a port name. (e.g.: COM1, COM2, ...)")
				PrintN(" * Device name refers to a port device path. (e.g.: \Device\Serial1, ...)")
				PrintN(" * Friendly name refers to a port name as seen in the device manager. (e.g.: Communications Port, USB-SERIAL CH340, ...)")
				PrintN(" * If an internal error occurs (1-9), the default options are used and the program returns the relevant error code.")
				PrintN(" * If a user-caused launch argument error occurs (10-19), the faulty option is ignored and the program returns the relevant error code.")
				PrintN(" * This approach to error hanlding is used to guarantee that something will be printed and that the output can be used if the error is not problematic.")
				PrintN("")
				PrintN("Formatting:")
				PrintN(" * No argument:")
				PrintN(" |_> $RawName => COM1")
				PrintN(" * '-d' or '-f' ")
				PrintN(" |_> $DeviceName => \Device\Serial1")
				PrintN(" |_> $FriendlyName => Communications Port")
				PrintN(" * '-d' and '-f' ")
				PrintN(" |_> $FriendlyName [$DeviceName] => Communications Port [\Device\Serial1]")
				PrintN(" * '-n' and '-d'")
				PrintN(" |_> $RawName [$DeviceName] => COM1 [\Device\Serial1]")
				PrintN(" * '-n' and '-f'")
				PrintN(" |_> $RawName - $FriendlyName => COM1 - Communications Port")
				PrintN(" * '-n' and '-d' and '-f'")
				PrintN(" |_> $RawName - $FriendlyName [$DeviceName] => COM1 - Communications Port [\Device\Serial1]")
				SerialHelper::Finish()
				End ExitCode
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
			
			If *DividerCharOption\WasUsed
				If ListSize(*DividerCharOption\Arguments()) = 0
					ConsoleError("No arguments given to -D or --divider, ignoring it !")
					ExitCode = 4
				Else
					FirstElement(*DividerCharOption\Arguments())
					PaddingString$ = *DividerCharOption\Arguments()
					
					;If Len(*DividerCharOption\Arguments()) = 0
					;	ConsoleError("No valid arguments given to -D or --divider, ignoring it !")
					;	ExitCode = 4
					;Else
					;	PaddingString$ = *DividerCharOption\Arguments()
					;EndIf
				EndIf
			EndIf
			
			If *NameTabPaddingOption\WasUsed
				PaddingString$ = #TAB$
			EndIf
		Else
			ConsoleError("Failed to parse arguments, using default options !")
			ExitCode = 1
		EndIf
	Else
		ConsoleError("Failed to register one or more agrument, not parsing arguments...")
		ExitCode = 2
	EndIf
	
	; Clearing the memory for the argument parser...
	Arguments::Finish()
Else
	ConsoleError("Failed to initialize the internal argument parser, ignoring them and printing the raw names...")
	ExitCode = 3
EndIf


;-> Listing ports

Global IsDoingFine.b = #True
Global NewMap ComPortDeviceNames.s()
Global NewList ComPortRawNames.s()
Global NewMap ComPortFriendlyNames.s() ; May not be used depending on the options used.

Global RawToFriendlySeparator$ = " - "
Global UseDeviceBrackets.b = #True

If PaddingString$ = #Null$
	; No custom padding char was used
	PaddingString$ = " "
Else
	; Custom padding char was used
	RawToFriendlySeparator$ = PaddingString$
	UseDeviceBrackets = #False
EndIf


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
				Print(RawToFriendlySeparator$+ComPortFriendlyNames(ComPortRawNames()))
			EndIf
			
			If ShouldPrintDeviceNames
				If UseDeviceBrackets
					PrintN(PaddingString$+"["+ComPortDeviceNames(ComPortRawNames())+"]")
				Else
					PrintN(PaddingString$+ComPortDeviceNames(ComPortRawNames()))
				EndIf
			Else
				Print(#CRLF$)
			EndIf
		Else
			If ShouldPrintFriendlyNames
				Print(ComPortFriendlyNames(ComPortRawNames()))
				If ShouldPrintDeviceNames
					If UseDeviceBrackets
						PrintN(PaddingString$+"["+ComPortDeviceNames(ComPortRawNames())+"]")
					Else
						PrintN(PaddingString$+ComPortDeviceNames(ComPortRawNames()))
					EndIf
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
End ExitCode
