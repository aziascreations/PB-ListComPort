;{
; * Arguments.pbi
; Version: 0.0.3
; Author: Herwin Bozet
; 
; A basic arguments parser.
;
; License: Unlicense (Public Domain)
;}

;- Compiler Directives

EnableExplicit


;- Code

If Not OpenConsole("lscom")
	; TODO: Play Windows error bell sound
	End 1
EndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	XIncludeFile "./Includes/SerialHelper_Win32.pbi"
CompilerElse
	CompilerError "Non-windows platforms are not supported !"
CompilerEndIf

XIncludeFile "./Includes/Arguments.pbi"


;-> Preparing arguments

Define ShouldPrintNames.b = #False
Define ShouldPrintDeviceNames.b = #False

If Arguments::Init()
	Define HasRegisteredArgumentsCorrectly.b = #True
	
	Define *HelpOption.Arguments::Option = Arguments::CreateOption('h', "help", "Display the help text")
	If Not Arguments::RegisterOption(*HelpOption)
		ConsoleError("Failed to register *HelpOption !")
		Arguments::FreeOption(*HelpOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	Define *NameOption.Arguments::Option = Arguments::CreateOption('n', "show-name", "Displays the port's full name")
	If Not Arguments::RegisterOption(*NameOption)
		ConsoleError("Failed to register *NameOption !")
		Arguments::FreeOption(*NameOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	Define *DeviceNameOption.Arguments::Option = Arguments::CreateOption('d', "show-device", "Displays the port's device name")
	If Not Arguments::RegisterOption(*DeviceNameOption)
		ConsoleError("Failed to register *DeviceNameOption !")
		Arguments::FreeOption(*DeviceNameOption)
		HasRegisteredArgumentsCorrectly = #False
	EndIf
	
	If HasRegisteredArgumentsCorrectly
		If Not Arguments::ParseArguments(0, CountProgramParameters())
			If *HelpOption\WasUsed
				PrintN("lscom.exe [-d|--show-device] [-h|--help] [-n|--show-name]")
				PrintN("")
				PrintN("Arguments:")
				PrintN("-d, --show-device  Displays the port's device name")
				PrintN("-h, --help         Display the help text")
				PrintN("-n, --show-name    Displays the port's full name")
				PrintN("-s, --sort         ???")
				PrintN("-S, --sort-reverse ???")
				End 0
			EndIf
			
			If *NameOption\WasUsed
				ShouldPrintNames = #True
			EndIf
			
			If *DeviceNameOption\WasUsed
				ShouldPrintDeviceNames = #True
			EndIf
		Else
			ConsoleError("Failed to parse arguments !")
		EndIf
	Else
		ConsoleError("Failed to register one or more agrument, not parsing arguments...")
	EndIf
	
	Arguments::Finish()
Else
	ConsoleError("Failed to initialize the internal argument parser, ignoring them...")
EndIf


;-> Listing ports

If ShouldPrintNames
	ConsoleError("Names are not supported yet !")
EndIf

NewList ComPorts.s()

SerialHelper::GetComPortList(ComPorts())

ForEach ComPorts()
	PrintN(SerialHelper::FormatComPortName(ComPorts()))
Next

FreeList(ComPorts())
