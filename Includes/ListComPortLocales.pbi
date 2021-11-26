;{- Code Header
; ==- Basic Info -================================
;         Name: ListComPortLocales.pbi
;      Version: N/A
;       Author: Herwin Bozet
; 
; ==- Links & License -===========================
;  License: Unlicense
;}

;- Notes

; Please refer to the following URL for the usable language codes:
; https://github.com/sokil/php-isocodes/blob/3.0/databases/iso_639-3.json


;- Compiler Directives

EnableExplicit

CompilerIf Not Defined(PBListComPortLang, #PB_Constant)
	CompilerWarning "#PBListComPortLang$ was not defined, using 'eng' as a fallback !"
	#PBListComPortLang = "eng"
CompilerEndIf


;- Locales

#LSCOM_Locale_LangCode$ = #PBListComPortLang


;-> English (eng)

CompilerIf #PBListComPortLang = "eng"
	#LSCOM_Locale_LangName$ = "English"
	
	#LSCOM_Locale_HelpSection_LaunchArgs$ = "Launch arguments"
	#LSCOM_Locale_HelpSection_Remarks$ = "Remarks"
	#LSCOM_Locale_HelpSection_Formatting$ = "Formatting"
	#LSCOM_Locale_HelpSection_ErrorCodes$ = "Error codes"
	
	#LSCOM_Locale_HelpSection_ErrorCodes_Fatal$ = "Fatal errors"
	#LSCOM_Locale_HelpSection_ErrorCodes_Internal$ = "Internal argument parser errors"
	#LSCOM_Locale_HelpSection_ErrorCodes_External$ = "External argument errors"
	#LSCOM_Locale_HelpSection_ErrorCodes_Application$ = "Application and system errors"
	
	#LSCOM_Locale_Expression_NoArguments$ = "No launch arguments"
	#LSCOM_Locale_Expression_RawName$ = "Raw name"
	#LSCOM_Locale_Expression_DeviceName$ = "Device name"
	#LSCOM_Locale_Expression_FriendlyName$ = "Friendly name"
	#LSCOM_Locale_Expression_Language$ = "Language"
	
	#LSCOM_Locale_Expression_LowerCase_Or$ = "or"
	#LSCOM_Locale_Expression_LowerCase_And$ = "and"
	
	#LSCOM_Locale_ArgumentDesc_ShowAll$ = "Display the complete port's name (Equal to '-dfn')"
	#LSCOM_Locale_ArgumentDesc_ShowDevice$ = "Displays the port's device name"
	#LSCOM_Locale_ArgumentDesc_Divider$ = "Uses the given string or char as a separator (Can be empty string !)"
	#LSCOM_Locale_ArgumentDesc_ShowFriendly$ = "Displays the port's friendly name"
	#LSCOM_Locale_ArgumentDesc_Help$ = "Display this help text"
	#LSCOM_Locale_ArgumentDesc_History$ = "Display ??? (Ignores -d, -f & -n )"
	#LSCOM_Locale_ArgumentDesc_ShowRaw$ = "Displays the port's raw name (See remarks section)"
	#LSCOM_Locale_ArgumentDesc_NoPadding$ = "Disable the automatic padding after the raw name"
	#LSCOM_Locale_ArgumentDesc_NoPretty$ = "Disables the pretty printing format (Equal to -D "+#DQUOTE$+" "+#DQUOTE$+")"
	#LSCOM_Locale_ArgumentDesc_Sort$ = "Sorts the port based on their raw names in an ascending order"
	#LSCOM_Locale_ArgumentDesc_SortReverse$ = "Sorts the port based on their raw names in a descending order"
	#LSCOM_Locale_ArgumentDesc_TabDivider$ = "Use tabs for padding between the types of names (Overrides '-D')"
	#LSCOM_Locale_ArgumentDesc_Version$ = "Shows the utility's version number and other info"
	#LSCOM_Locale_ArgumentDesc_VersionOnly$ = "Shows the utility's version number only (Overrides '-v')"
	
	#LSCOM_Locale_Remark_NamePartsAndRawDefault$ = "If '-d' or '-f' is used, the raw name will not be shown unless '-n' is used."
	#LSCOM_Locale_Remark_NoPrettyPrinting$ = "If '-D', '-t' or '-p' are used, the special separator between the raw and friendly name and the square brackets are not shown."
	#LSCOM_Locale_Remark_DefaultSorting$ = "By default, the ports are sorted in the order they are provided by the registry, which is often chronological."
	#LSCOM_Locale_Remark_NameRaw$ = "The 'raw name' refers to a port name. (e.g.: COM1, COM2, ...)"
	#LSCOM_Locale_Remark_NameDevice$ = "The 'device name' refers to a port device path. (e.g.: \Device\Serial1, ...)"
	#LSCOM_Locale_Remark_NameFriendly$ = "The 'friendly name' refers to a port name as seen in the device manager. (e.g.: Communications Port, USB-SERIAL CH340, ...)"
	#LSCOM_Locale_Remark_ErrorsFatal$ = "Any result returned with an error code between 1-9 and 30-39 should be considered as invalid."
	#LSCOM_Locale_Remark_ErrorsNonFatal$ = "Any result returned with another error code is valid but probably not formatted properly."
	
	#LSCOM_Locale_Error_MBTitle$ = "Fatal error !"
	#LSCOM_Locale_Error_MBText$ = "Failed to open the console !"
	
	#LSCOM_Locale_Error_WinApiMissingFunction$ = "Cannot continue without being able to use RegGetValueW() !"
	#LSCOM_Locale_Error_ArgumentDefinitionFailure$ = "Failed to register argument ! (Caused by %0)"
	
	#LSCOM_Locale_ErrorExplaination_NoTerminal$ = "The app couldn't open a console to print to it."
	#LSCOM_Locale_ErrorExplaination_WinApiMissingFunction$ = "The app can't find 'RegGetValueW' in 'Advapi32.dll'. (No longer used !)"
	#LSCOM_Locale_ErrorExplaination_ArgumentParsingFailure$ = "Failed to parse the launch arguments, default options will be used."
	#LSCOM_Locale_ErrorExplaination_ArgumentDefinitionFailure$ = "Failed to register one or more argument, arguments will not be parsed."
	#LSCOM_Locale_ErrorExplaination_ArgumentInitFailure$ = "Failed to initialize the internal argument parser, they will be entirely ignored."
	#LSCOM_Locale_ErrorExplaination_NoPaddingValue$ = "No value can be found for the '-D' argument, it will be ignored."
	#LSCOM_Locale_ErrorExplaination_NoFriendlyNames$ = "No friendly name could be found."
	#LSCOM_Locale_ErrorExplaination_NoComPorts$ = "No COM port could be found."
CompilerEndIf


;-> French (fra)

CompilerIf #PBListComPortLang = "fra"
	#LSCOM_Locale_LangName$ = "Français"
	
	#LSCOM_Locale_HelpSection_LaunchArgs$ = "Options de lancement"
	#LSCOM_Locale_HelpSection_Remarks$ = "Remarques"
	#LSCOM_Locale_HelpSection_Formatting$ = "Format de sortie"
	#LSCOM_Locale_HelpSection_ErrorCodes$ = "Codes d'erreur"
	
	#LSCOM_Locale_HelpSection_ErrorCodes_Fatal$ = "Erreurs fatales"
	#LSCOM_Locale_HelpSection_ErrorCodes_Internal$ = "Erreurs interne au processeur d'arguments de lancement"
	#LSCOM_Locale_HelpSection_ErrorCodes_External$ = "Erreurs externes aux arguments de lancement"
	#LSCOM_Locale_HelpSection_ErrorCodes_Application$ = "Erreurs liées à l'application et à l'OS"
	
	#LSCOM_Locale_Expression_NoArguments$ = "Aucunes options de lancement"
	#LSCOM_Locale_Expression_RawName$ = "Nom brut"
	#LSCOM_Locale_Expression_DeviceName$ = "Nom appareil"
	#LSCOM_Locale_Expression_FriendlyName$ = "Nom familier"
	#LSCOM_Locale_Expression_Language$ = "Langue"
	
	#LSCOM_Locale_Expression_LowerCase_Or$ = "ou"
	#LSCOM_Locale_Expression_LowerCase_And$ = "et"
	
	#LSCOM_Locale_ArgumentDesc_ShowAll$ = "Affiche le nom complet du port (Équivalent à '-dfn')"
	#LSCOM_Locale_ArgumentDesc_ShowDevice$ = "Affiche le nom d'appareil du port"
	#LSCOM_Locale_ArgumentDesc_Divider$ = "Utilise le texte donné comme séparateur de type de nom (Peut être vide !)"
	#LSCOM_Locale_ArgumentDesc_ShowFriendly$ = "Affiche le nom familier du port"
	#LSCOM_Locale_ArgumentDesc_Help$ = "Affiche ce texte d'aide"
	#LSCOM_Locale_ArgumentDesc_History$ = "Affiche uniquement l'historique des ports connus"
	#LSCOM_Locale_ArgumentDesc_ShowRaw$ = "Affiche le nom brut des ports (Voir la section '"+#LSCOM_Locale_HelpSection_Remarks$+"')"
	#LSCOM_Locale_ArgumentDesc_NoPadding$ = "Disable the automatic padding after the raw name"
	#LSCOM_Locale_ArgumentDesc_NoPretty$ = "Désactive le format d'impression propre (Équivalent à -D "+#DQUOTE$+" "+#DQUOTE$+")"
	#LSCOM_Locale_ArgumentDesc_Sort$ = "Trie les ports par ordre alphabétique selon leur nom brut"
	#LSCOM_Locale_ArgumentDesc_SortReverse$ = "Trie les ports par ordre alphabétique inversé selon leur nom bru"
	#LSCOM_Locale_ArgumentDesc_TabDivider$ = "Utilise une tabulation comme séparateur (Ignore '-D')"
	#LSCOM_Locale_ArgumentDesc_Version$ = "Affiche le numéro de version et d'autres info sur le programme"
	#LSCOM_Locale_ArgumentDesc_VersionOnly$ = "Affiche uniquement le numéro de version du programme (Ignore '-v')"
	
	#LSCOM_Locale_Remark_NamePartsAndRawDefault$ = "Si '-d' ou '-f' sont utilisés, le nom brut ne sera pas affiché tant que '-n' n'est pas aussi utilisé."
	#LSCOM_Locale_Remark_NoPrettyPrinting$ = "Si '-D', '-t' ou '-p' sont utilisés, le séparateur spécial entre le nom brut et familier, ainsi que les crochets ne seront pas affichés."
	#LSCOM_Locale_Remark_DefaultSorting$ = "Par défaut, les ports sont triés dans l'ordre du registre qui est souvent chronologique."
	#LSCOM_Locale_Remark_NameRaw$ = "Le 'nom brut' se réfère au nom du port. (ex: COM1, COM2, ...)"
	#LSCOM_Locale_Remark_NameDevice$ = "Le 'nom d'appareil' se rèfère au chemin sous lequel le port peut être accédé. (ex: \Device\Serial1, ...)"
	#LSCOM_Locale_Remark_NameFriendly$ = "Le 'nom familier' se féfère au nom du port visible dans le gestionnaire de pérphériques. (ex: Communications Port, USB-SERIAL CH340, ...)"
	#LSCOM_Locale_Remark_ErrorsFatal$ = "Tout résultat retourné avec un code d'erreur entre 1-9 et 30-39 doit être considéré comme invalide."
	#LSCOM_Locale_Remark_ErrorsNonFatal$ = "Tout résultat retourné avec un autre code d'erreur est valide mais potentiellement mal formaté."
	
	#LSCOM_Locale_Error_MBTitle$ = "Erreur critique !"
	#LSCOM_Locale_Error_MBText$ = "Impossible d'ouvrir un invité de commande !"
	
	#LSCOM_Locale_Error_WinApiMissingFunction$ = "Impossible de continuer sans accès à RegGetValueW() !"
	#LSCOM_Locale_Error_ArgumentDefinitionFailure$ = "Échec d'enregistrement d'argument de lancement ! (Causé par %0)"
	
	#LSCOM_Locale_ErrorExplaination_NoTerminal$ = "Le programme n'a pas réussi à avoir accès à un invité de commande."
	#LSCOM_Locale_ErrorExplaination_WinApiMissingFunction$ = "Le programme ne peut pas trouver la fonction 'RegGetValueW' dans 'Advapi32.dll'. (N'est plus retourné !)"
	#LSCOM_Locale_ErrorExplaination_ArgumentParsingFailure$ = "Erreur de lecture des arguments de lancement, ils seront ignorés."
	#LSCOM_Locale_ErrorExplaination_ArgumentDefinitionFailure$ = "Erreur de définition des arguments de lancement, ils seront ignorés."
	#LSCOM_Locale_ErrorExplaination_ArgumentInitFailure$ = "Erreur d'initialisation du lecteur arguments de lancement, ils seront ignorés."
	#LSCOM_Locale_ErrorExplaination_NoPaddingValue$ = "Aucune valeur n'existe pour l'argument '-D', il sera ignoré."
	#LSCOM_Locale_ErrorExplaination_NoFriendlyNames$ = "Aucun nom familier n'a pu être trouvé."
	#LSCOM_Locale_ErrorExplaination_NoComPorts$ = "Aucun port COM n'a pu être trouvé."
CompilerEndIf


;-> Commons

#LSCOM_Locale_HelpSectionFormatted_ErrorCodes_Fatal$ = " * "+#LSCOM_Locale_HelpSection_ErrorCodes_Fatal$+" (1-9):"
#LSCOM_Locale_HelpSectionFormatted_ErrorCodes_Internal$ = " * "+#LSCOM_Locale_HelpSection_ErrorCodes_Internal$+" (10-19):"
#LSCOM_Locale_HelpSectionFormatted_ErrorCodes_External$ = " * "+#LSCOM_Locale_HelpSection_ErrorCodes_External$+" (20-29):"
#LSCOM_Locale_HelpSectionFormatted_ErrorCodes_Application$ = " * "+#LSCOM_Locale_HelpSection_ErrorCodes_Application$+" (30-39):"
