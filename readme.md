# PB-ListComPort

A simple cli tool that can list COM ports with their full name easily and cleanly.

This tool is intended to replace the tedious task of having to use the `mode` command, and the *Device Manager* to find
a newly plugged-in device that provides a COM port.

The earliest version of Windows that can be used is Windows XP x64 or Windows Vista due to the fact that [RegGetValueW](https://docs.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-reggetvaluew)
is not available on older versions of Windows.

The latest releases can be found here: "*[Release page](https://github.com/aziascreations/PB-ListComPort/releases)*"

## Usage
```
lscom.exe [-a|--show-all] [-d|--show-device] [-D <str>|--divider <str>] [-f|--show-friendly]
          [-h|--help] [-n|--show-name-raw] [-P|--no-pretty] [-s|--sort] [-S|--sort-reverse]
          [-t|--tab-padding] [-v|--version] [-V|--version-only]

Launch arguments:
 -a, --show-all             Display the complete port's name (Equal to '-dfn')
 -d, --show-device          Displays the port's device name
 -D <str>, --divider <str>  Uses the given string or char as a separator (Can be empty string !)
 -f, --show-friendly        Displays the port's friendly name
 -h, --help                 Display this help text
 -n, --show-name-raw        Displays the port's raw name (See remarks section)
 -P, --no-pretty            Disables the pretty printing format (Equal to -D " ")
 -s, --sort                 Sorts the port based on their raw names in an ascending order
 -S, --sort-reverse         Sorts the port based on their raw names in a descending order
 -t, --tab-padding          Use tabs for padding between the types of names (Overrides '-D')
 -v, --version              Shows the utility's version number and other info
 -V, --version-only         Shows the utility's version number only (Overrides '-v')
```

## Remarks
 * If '-d' or '-f' is used, the raw name will not be shown unless '-n' is used.
 * If '-D', '-t' or '-p' are used, the special separator between the raw and friendly name and the square brackets are not shown.
 * The 'raw name' refers to a port name. (e.g.: COM1, COM2, ...)
 * The 'device name' refers to a port device path. (e.g.: \Device\Serial1, ...)
 * The 'friendly name' refers to a port name as seen in the device manager. (e.g.: Communications Port, USB-SERIAL CH340, ...)
 * Any result returned with an error code between 1-9 and 30-39 should be considered as invalid.
 * Any result returned with another error code is valid but probably not formatted properly.

## Output formatting
```
 *┬> No launch arguments:
  └──> ${Raw name}      => COM1
 *┬> '-d' or '-f'
  ├──> ${Device name}   => \Device\Serial1
  └──> ${Friendly name} => Communications Port
 *┬> '-d' and '-f'
  └──> ${Friendly name} [${Device name}]        => Communications Port [\Device\Serial1]
 *┬> '-n' and '-d'
  └──> ${Raw name} [$DeviceName]        => COM1 [\Device\Serial1]
 *┬> '-n' and '-f'
  └──> ${Raw name} - ${Friendly name}   => COM1 - Communications Port
 *┬> '-ndf' or '-a'
  └──> ${Raw name} - ${Friendly name} [${Device name}]  => COM1 - Communications Port [\Device\Serial1]
 *┬> '-ndfp' or '-ap'
  └──> ${Raw name} ${Friendly name} ${Device name}      => COM1 Communications Port \Device\Serial1
 *┬> '-ndfD ";"' or '-aD ";"'
  └──> ${Raw name};${Friendly name};${Device name}      => COM1;Communications Port;\Device\Serial1
```

## Error codes
 * Fatal errors (1-9):
   * 1 - The app couldn't open a console to print to it.
   * 2 - The app can't find 'RegGetValueW' in 'Advapi32.dll'.
 * Internal argument parser errors (10-19):
   * 10 - Failed to parse the launch arguments, default options will be used.
   * 11 - Failed to register one or more argument, arguments will not be parsed.
   * 12 - Failed to initialize the internal argument parser, they will be entirely ignored.
 * External argument errors (20-29):
   * 20 - No value can be found for the '-D' argument, it will be ignored.
 * Application and system errors (30-39):
   * 30 - No friendly name could be found.
   * 31 - No COM port could be found.

## License
[Unlicense](LICENSE)
