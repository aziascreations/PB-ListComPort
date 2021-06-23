# PB-ListComPort

A simple cli tool that can list COM ports with their full name easily and cleanly.

This tool is intended to replace the tedious task of having to use the `mode` command, and the *Device Manager* to find
a newly plugged-in device that provides a COM port.

Only works on x64 releases of Windows 10, it might work on older versions, but I won't explicitly support
them as they have reached their EOL.

## Usage
```
lscom.exe [-a|--show-all] [-d|--show-device] [-f|--show-friendly] [-h|--help] [-n|--show-name-raw] [-s|--sort] [-S|--sort-reverse]

Arguments:
-a, --show-all       Display the complete port's name (Equal to '-dfn')
-d, --show-device    Displays the port's device name
-f, --show-friendly  Displays the port's friendly name
-h, --help           Display the help text
-n, --show-name-raw  Displays the port's raw name (See info section)
-s, --sort           Sorts the port based on their raw names in an ascending order
-S, --sort-reverse   Sorts the port based on their raw names in a descending order
```

## Remarks
 * If '-d' or '-f' is used, the raw name will not be shown unless '-n' is used.
 * By default, the order the ports are shown in SHOULD be the [plug-in time] order from Windows' registry.
 * Searching for the friendly names can be a time consuming task !
 * Raw name simply refers to a port name (e.g.: COM1, COM2, ...)
 * Device name refers to a port device path (e.g.: \Device\Serial1, ...)
 * Friendly name refers to a port name as seen in the device manager (e.g.: Communications Port, USB-SERIAL CH340, )

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
