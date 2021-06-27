;{
; * ListComPort.pb
; Version: 2.0.0
; Author: Herwin Bozet
;
; License: Unlicense (Public Domain)
;}

;- Notes

; No notes currently available.


;- Compiler Directives

EnableExplicit

CompilerIf #PB_Compiler_ExecutableFormat <> #PB_Compiler_Console
	CompilerError("this program need to be compiled as a console application !")
CompilerEndIf


;- Constants

#Version$ = "2.0.0"

XIncludeFile "./ListComPortLocales.pbi"
XIncludeFile "./ListComPortErrorCodes.pbi"

#Sort_Order_Descending = -1
#Sort_Order_None = 0
#Sort_Order_Ascending = 1


;- Code

;-> Setup

If Not OpenConsole("lscom")
	MessageBeep_(#MB_ICONERROR)
	MessageRequester(#LSCOM_Locale_Error_MBTitle$, #LSCOM_Locale_Error_MBText$,
	                 #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
	End #LSCOM_ErrorCode_NoTerminal
EndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	XIncludeFile "./Includes/SerialHelper_Win32.pbi"
	
	If Not SerialHelper::RegGetValueW
		ConsoleError(#LSCOM_Locale_ErrorExplaination_WinApiMissingFunction$ + #CRLF$ + #LSCOM_Locale_Error_WinApiMissingFunction$)
		SerialHelper::Finish()
		End #LSCOM_ErrorCode_NoRequiredWinApiFunction
	EndIf
CompilerElse
	CompilerError "Non-windows platforms are not supported !"
CompilerEndIf

XIncludeFile "./Includes/Arguments.pbi"


;-> Preparing globals

Global ExitCode.i = #LSCOM_ErrorCode_NoError

Global ShouldPrintRawNames.b = #True
Global ShouldPrintDeviceNames.b = #False
Global ShouldPrintFriendlyNames.b = #False
Global SortingOrder.b = #Sort_Order_None
Global PaddingString$ = #Null$


;-> Preparing argument parser

Procedure VerifyOption(*Option, OptionName$, *HasRegisteredArgumentsCorrectly)
	If Not Arguments::RegisterOption(*Option)
		ConsoleError(ReplaceString(#LSCOM_Locale_Error_ArgumentDefinitionFailure$, "%0", OptionName$))
		Arguments::FreeOption(*Option)
		PokeB(*HasRegisteredArgumentsCorrectly, #False)
	EndIf
EndProcedure

If Arguments::Init()
	Define HasRegisteredArgumentsCorrectly.b = #True
	
	Define *NameAllOption.Arguments::Option = Arguments::CreateOption('a', "show-all", #LSCOM_Locale_ArgumentDesc_ShowAll$)
	Define *NameDeviceOption.Arguments::Option = Arguments::CreateOption('d', "show-device", #LSCOM_Locale_ArgumentDesc_ShowDevice$)
	Define *DividerCharOption.Arguments::Option = Arguments::CreateOption('D', "divider", #LSCOM_Locale_ArgumentDesc_Divider$, Arguments::#Option_HasValue)
	Define *NameFriendlyOption.Arguments::Option = Arguments::CreateOption('f', "show-friendly", #LSCOM_Locale_ArgumentDesc_ShowFriendly$)
	Define *HelpOption.Arguments::Option = Arguments::CreateOption('h', "help", #LSCOM_Locale_ArgumentDesc_Help$)
	Define *NameRawOption.Arguments::Option = Arguments::CreateOption('n', "show-name-raw", #LSCOM_Locale_ArgumentDesc_ShowRaw$)
	Define *NoPrettyAscOption.Arguments::Option = Arguments::CreateOption('P', "no-pretty", #LSCOM_Locale_ArgumentDesc_NoPretty$)
	Define *SortAscOption.Arguments::Option = Arguments::CreateOption('s', "sort", #LSCOM_Locale_ArgumentDesc_Sort$)
	Define *SortDescOption.Arguments::Option = Arguments::CreateOption('S', "sort-reverse", #LSCOM_Locale_ArgumentDesc_SortReverse$)
	Define *NameTabPaddingOption.Arguments::Option = Arguments::CreateOption('t', "tab-padding", #LSCOM_Locale_ArgumentDesc_TabDivider$)
	Define *VersionOption.Arguments::Option = Arguments::CreateOption('v', "version", #LSCOM_Locale_ArgumentDesc_Version$)
	Define *VersionOnlyOption.Arguments::Option = Arguments::CreateOption('V', "version-only", #LSCOM_Locale_ArgumentDesc_VersionOnly$)
	
	VerifyOption(*NameAllOption, "*NameAllOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*NameDeviceOption, "*NameDeviceOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*DividerCharOption, "*DividerCharOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*NameFriendlyOption, "*NameFriendlyOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*HelpOption, "*HelpOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*NameRawOption, "*NameRawOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*NoPrettyAscOption, "*NoPrettyAscOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*SortAscOption, "*SortAscOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*SortDescOption, "*SortDescOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*NameTabPaddingOption, "*NameTabPaddingOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*VersionOption, "*VersionOption", @HasRegisteredArgumentsCorrectly)
	VerifyOption(*VersionOnlyOption, "*VersionOnlyOption", @HasRegisteredArgumentsCorrectly)
	
	If HasRegisteredArgumentsCorrectly
		If Not Arguments::ParseArguments(0, CountProgramParameters())
			If *HelpOption\WasUsed
				PrintN("lscom.exe [-a|--show-all] [-d|--show-device] [-D <str>|--divider <str>] [-f|--show-friendly]")
				PrintN("          [-h|--help] [-n|--show-name-raw] [-P|--no-pretty] [-s|--sort] [-S|--sort-reverse]")
				PrintN("          [-t|--tab-padding] [-v|--version] [-V|--version-only]")
				PrintN("")
				
				PrintN(#LSCOM_Locale_HelpSection_LaunchArgs$+":")
				PrintN(" -a, --show-all             "+#LSCOM_Locale_ArgumentDesc_ShowAll$)
				PrintN(" -d, --show-device          "+#LSCOM_Locale_ArgumentDesc_ShowDevice$)
				PrintN(" -D <str>, --divider <str>  "+#LSCOM_Locale_ArgumentDesc_Divider$)
				PrintN(" -f, --show-friendly        "+#LSCOM_Locale_ArgumentDesc_ShowFriendly$)
				PrintN(" -h, --help                 "+#LSCOM_Locale_ArgumentDesc_Help$)
				PrintN(" -n, --show-name-raw        "+#LSCOM_Locale_ArgumentDesc_ShowRaw$)
				PrintN(" -P, --no-pretty            "+#LSCOM_Locale_ArgumentDesc_NoPretty$)
				PrintN(" -s, --sort                 "+#LSCOM_Locale_ArgumentDesc_Sort$)
				PrintN(" -S, --sort-reverse         "+#LSCOM_Locale_ArgumentDesc_SortReverse$)
				PrintN(" -t, --tab-padding          "+#LSCOM_Locale_ArgumentDesc_TabDivider$)
				PrintN(" -v, --version              "+#LSCOM_Locale_ArgumentDesc_Version$)
				PrintN(" -V, --version-only         "+#LSCOM_Locale_ArgumentDesc_VersionOnly$)
				PrintN("")
				
				PrintN(#LSCOM_Locale_HelpSection_Remarks$+":")
				PrintN(" * "+#LSCOM_Locale_Remark_NamePartsAndRawDefault$)
				PrintN(" * "+#LSCOM_Locale_Remark_NoPrettyPrinting$)
				PrintN(" * "+#LSCOM_Locale_Remark_NameRaw$)
				PrintN(" * "+#LSCOM_Locale_Remark_NameDevice$)
				PrintN(" * "+#LSCOM_Locale_Remark_NameFriendly$)
				PrintN(" * "+#LSCOM_Locale_Remark_ErrorsFatal$)
				PrintN(" * "+#LSCOM_Locale_Remark_ErrorsNonFatal$)
				PrintN("")
				
				PrintN(#LSCOM_Locale_HelpSection_Formatting$+":")
				PrintN(" *┬> "+#LSCOM_Locale_Expression_NoArguments$+":")
				PrintN("  └──> ${"+#LSCOM_Locale_Expression_RawName$+"}"+#TAB$+"=> COM1")
				PrintN(" *┬> '-d' "+#LSCOM_Locale_Expression_LowerCase_Or$+" '-f' ")
				PrintN("  ├──> ${"+#LSCOM_Locale_Expression_DeviceName$+"}"+#TAB$+"=> \Device\Serial1")
				PrintN("  └──> ${"+#LSCOM_Locale_Expression_FriendlyName$+"}"+#TAB$+"=> Communications Port")
				PrintN(" *┬> '-d' "+#LSCOM_Locale_Expression_LowerCase_And$+" '-f' ")
				PrintN("  └──> ${"+#LSCOM_Locale_Expression_FriendlyName$+"} [${"+#LSCOM_Locale_Expression_DeviceName$+"}]"+#TAB$+"=> Communications Port [\Device\Serial1]")
				PrintN(" *┬> '-n' "+#LSCOM_Locale_Expression_LowerCase_And$+" '-d'")
				PrintN("  └──> ${"+#LSCOM_Locale_Expression_RawName$+"} [$DeviceName]"+#TAB$+"=> COM1 [\Device\Serial1]")
				PrintN(" *┬> '-n' "+#LSCOM_Locale_Expression_LowerCase_And$+" '-f'")
				PrintN("  └──> ${"+#LSCOM_Locale_Expression_RawName$+"} - ${"+#LSCOM_Locale_Expression_FriendlyName$+"}"+#TAB$+"=> COM1 - Communications Port")
				PrintN(" *┬> '-ndf' "+#LSCOM_Locale_Expression_LowerCase_Or$+" '-a' ")
				PrintN("  └──> ${"+#LSCOM_Locale_Expression_RawName$+"} - ${"+#LSCOM_Locale_Expression_FriendlyName$+"} [${"+#LSCOM_Locale_Expression_DeviceName$+"}]"+
				       #TAB$+"=> COM1 - Communications Port [\Device\Serial1]")
				PrintN(" *┬> '-ndfp' "+#LSCOM_Locale_Expression_LowerCase_Or$+" '-ap' ")
				PrintN("  └──> ${"+#LSCOM_Locale_Expression_RawName$+"} ${"+#LSCOM_Locale_Expression_FriendlyName$+"} ${"+#LSCOM_Locale_Expression_DeviceName$+"}"+
				       #TAB$+"=> COM1 Communications Port \Device\Serial1")
				PrintN(" *┬> '-ndfD "+#DQUOTE$+";"+#DQUOTE$+"' "+#LSCOM_Locale_Expression_LowerCase_Or$+" '-aD "+#DQUOTE$+";"+#DQUOTE$+"' ")
				PrintN("  └──> ${"+#LSCOM_Locale_Expression_RawName$+"};${"+#LSCOM_Locale_Expression_FriendlyName$+"};${"+#LSCOM_Locale_Expression_DeviceName$+"}"+
				       #TAB$+"=> COM1;Communications Port;\Device\Serial1")
				PrintN("")
				
				PrintN(#LSCOM_Locale_HelpSection_ErrorCodes$+":")
				PrintN(#LSCOM_Locale_HelpSectionFormatted_ErrorCodes_Fatal$)
				PrintN("   * "+Str(#LSCOM_ErrorCode_NoTerminal)+" - "+#LSCOM_Locale_ErrorExplaination_NoTerminal$)
				PrintN("   * "+Str(#LSCOM_ErrorCode_NoRequiredWinApiFunction)+" - "+#LSCOM_Locale_ErrorExplaination_WinApiMissingFunction$)
				
				PrintN(#LSCOM_Locale_HelpSectionFormatted_ErrorCodes_Internal$)
				PrintN("   * "+Str(#LSCOM_ErrorCode_ArgumentParsingFailure)+" - "+#LSCOM_Locale_ErrorExplaination_ArgumentParsingFailure$)
				PrintN("   * "+Str(#LSCOM_ErrorCode_ArgumentDefinitionFailure)+" - "+#LSCOM_Locale_ErrorExplaination_ArgumentDefinitionFailure$)
				PrintN("   * "+Str(#LSCOM_ErrorCode_ArgumentInitFailure)+" - "+#LSCOM_Locale_ErrorExplaination_ArgumentInitFailure$)
				
				PrintN(#LSCOM_Locale_HelpSectionFormatted_ErrorCodes_External$)
				PrintN("   * "+Str(#LSCOM_ErrorCode_NoPaddingValue)+" - "+#LSCOM_Locale_ErrorExplaination_NoPaddingValue$)
				
				PrintN(#LSCOM_Locale_HelpSectionFormatted_ErrorCodes_Application$)
				PrintN("   * "+Str(#LSCOM_ErrorCode_NoFriendlyNames)+" - "+#LSCOM_Locale_ErrorExplaination_NoFriendlyNames$)
				PrintN("   * "+Str(#LSCOM_ErrorCode_NoComPorts)+" - "+#LSCOM_Locale_ErrorExplaination_NoComPorts$)
				
				SerialHelper::Finish()
				End ExitCode
			EndIf
			
			If *VersionOption\WasUsed
				PrintN("PB-ListComPort (lscom) v"+#Version$)
				SerialHelper::Finish()
				End ExitCode
			EndIf
			
			If *VersionOnlyOption\WasUsed
				Print(#Version$)
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
			
			If *NoPrettyAscOption\WasUsed
				PaddingString$ = " "
			EndIf
			
			If *DividerCharOption\WasUsed
				If ListSize(*DividerCharOption\Arguments()) = 0
					ConsoleError(#LSCOM_Locale_ErrorExplaination_NoPaddingValue$)
					ExitCode = #LSCOM_ErrorCode_NoPaddingValue
				Else
					FirstElement(*DividerCharOption\Arguments())
					PaddingString$ = *DividerCharOption\Arguments()
				EndIf
			EndIf
			
			If *NameTabPaddingOption\WasUsed
				PaddingString$ = #TAB$
			EndIf
		Else
			ConsoleError(#LSCOM_Locale_ErrorExplaination_ArgumentParsingFailure$)
			ExitCode = #LSCOM_ErrorCode_ArgumentParsingFailure
		EndIf
	Else
		ConsoleError(#LSCOM_Locale_ErrorExplaination_ArgumentDefinitionFailure$)
		ExitCode = #LSCOM_ErrorCode_ArgumentDefinitionFailure
	EndIf
	
	; Clearing the memory for the argument parser...
	Arguments::Finish()
Else
	ConsoleError(#LSCOM_Locale_ErrorExplaination_ArgumentInitFailure$)
	ExitCode = #LSCOM_ErrorCode_ArgumentInitFailure
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
			ConsoleError(#LSCOM_Locale_ErrorExplaination_NoFriendlyNames$)
			IsDoingFine = #False
			ExitCode = #LSCOM_ErrorCode_NoFriendlyNames
		EndIf
	EndIf
Else
	ConsoleError(#LSCOM_Locale_ErrorExplaination_NoComPorts$)
	IsDoingFine = #False
	ExitCode = #LSCOM_ErrorCode_NoComPorts
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
