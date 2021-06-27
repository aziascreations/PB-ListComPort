# PB-ListComPort

A simple cli tool that can list COM ports with their full name easily and cleanly.

This tool is intended to replace the tedious task of having to use the `mode` command, and the *Device Manager* to find
a newly plugged-in device that provides a COM port.

The earliest version of Windows that can be used is Windows XP x64 or Windows Vista due to the fact that [RegGetValueW](https://docs.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-reggetvaluew)
is not available on older versions of Windows.

## Usage
```
lscom.exe [-a|--show-all] [-d|--show-device] [-D <str>|--divider <str>] [-f|--show-friendly]
          [-h|--help] [-n|--show-name-raw] [-s|--sort] [-S|--sort-reverse] [-t|--tab-padding]

Launch arguments:
-a, --show-all             Display the complete port's name (Equal to '-dfn')
-d, --show-device          Displays the port's device name
-D <str>, --divider <str>  Uses the given string or char as a separator (Can be empty string !)
-f, --show-friendly        Displays the port's friendly name
-h, --help                 Display the help text
-n, --show-name-raw        Displays the port's raw name (See info section)
-s, --sort                 Sorts the port based on their raw names in an ascending order
-S, --sort-reverse         Sorts the port based on their raw names in a descending order
-t, --tab-padding          Use tabs for padding between the types of names (Overrides -D)
```

## Remarks
 * If '-d' or '-f' is used, the raw name will not be shown unless '-n' is used.
 * By default, the order the ports are shown in SHOULD be the [plug-in time] order from Windows' registry.
 * Searching for the friendly names can be a time consuming task !
 * When -D or -t are used, the separator ' - ' between the raw and friendly name is set to the given separator.
 * Raw name simply refers to a port name. (e.g.: COM1, COM2, ...)
 * Device name refers to a port device path. (e.g.: \Device\Serial1, ...)
 * Friendly name refers to a port name as seen in the device manager. (e.g.: Communications Port, USB-SERIAL CH340, )
 * If an internal error occurs (1-9), the default options are used and the program returns the relevant error code.
 * If a user-caused launch argument error occurs (10-19), the faulty option is ignored and the program returns the relevant error code.
 * This approach to error hanlding is used to guarantee that something will be printed and that the output can be used if the error is not problematic.

## Output formatting
 * No argument:
   > $RawName<br>
     > COM1
 * '-d' or '-f'
   > $DeviceName
   > > \Device\Serial1
   > 
   > $FriendlyName
   > > Communications Port
 * '-d' and '-f'
   > $FriendlyName [$DeviceName]
   > > Communications Port [\Device\Serial1]
 * '-n' and '-d'
   > $RawName [$DeviceName]
   > > COM1 [\Device\Serial1]
 * '-n' and '-f'
   > $RawName - $FriendlyName
   > > COM1 - Communications Port
 * '-n' and '-d' and '-f'
   > $RawName - $FriendlyName [$DeviceName]
   > > COM1 - Communications Port [\Device\Serial1]

## License
[Unlicense](LICENSE)
