# SwifterLog
A single class framework in Swift to create and manage log entries.

SwifterLog is part of the [Swiftfire](http://swiftfire.nl) webserver project.

# Features

- 5 different logging targets:
	1. The Apple System Log facility
	2. A file
	3. STDOUT (println)
	4. A network destination
	5. A list of callback objects from the Application itself.
- 8 log levels, the same as defined for the Apple System Log facility:
	1. Debug
	2. Info
	3. Notice
	4. Warning
	5. Error
	6. Critical
	7. Alert
	8. Emergency
- Each logging target can have its own cut-off level for the information that is logged.
- The file target can be configured to store the log info in a predefined number of files of a predefined maximum size. When the maximum number of files is exceeded, the oldest file will automatically be removed.
- Includes xcode project that creates a modular framework.

# Documentation

Project website: [http://swiftfire.nl/projects/swiftfire/swiftfire.html](http://swiftfire.nl/projects/swiftfire/swiftfire.html)

Reference manual: [http://swiftfire.nl/projects/swiftfire/reference/index.html](http://swiftfire.nl/projects/swiftfire/reference/index.html)

Installation: [http://swiftfire.nl/projects/swifterlog/reference/installation.html](http://swiftfire.nl/projects/swifterlog/reference/installation.html) or on [github](https://github.com/Balancingrock/SwifterLog/blob/master/docs/Installation.md)

User Manual: [http://swiftfire.nl/projects/swifterlog/reference/usermanual.html](http://swiftfire.nl/projects/swifterlog/reference/usermanual.html) or on [github](https://github.com/Balancingrock/SwifterLog/blob/master/docs/UserManual.md)

# Version History

Note: Planned releases are for information only, they are subject to change without notice.

Maintenance updates are updates due to management of the (SPM) package hierarchy, they don't affect the source code.

#### v1.1.0 (Open)

- No new features planned. Features and bugfixes will be made on an ad-hoc basis as needed to support Swiftfire development.
- For feature requests and bugfixes please contact rien@balancingrock.nl

#### v1.0.0 (Planned)

- Version number will be increased to this level when Swiftfire 1.0.0 is released.

#### v0.9.18 (Current)

- Removed global 'log' definition, use SwifterLog.theLogger instead. (let log = SwifterLog.theLogger)
- Added faster loggers for disabled log levels. (eg: Log.atDebug?.log(...))

#### v0.9.17 (Current)

- Replaced local c-glue with CAsl glue library (now builds under SPM)

#### v0.9.15-16

- Maintenance updates

#### v0.9.14

- Changed distribution model
- Added reference manual (improved documentation)

#### v0.9.13

- Upgraded to Xcode 8 beta 6 (Swift 3)

#### v0.9.12

- Upgraded to Xcode 8 beta 3 (Swift 3)

#### v0.9.11

- Update to accomodate VJson v0.9.8

#### v0.9.10

- Update to accomodate VJson updates

#### v0.9.9

- Added 'public' to the string extensions
- Added 'ReflectedStringConvertible' (Idea from [Matt Comi](https://github.com/mattcomi))
- Changed message parameter from 'String' to 'Any' on all logging calls (Inspired by [whitehat007](https://github.com/whitehat007))
- Fixed bug that would not call the callback destination for the very first logging message
- Added a few unit tests

#### v0.9.8:

- Header update to include new website: [swiftfire.nl](http://swiftfire.nl)
- Renamed SwifterLogNetwork.swift to SwifterLog.Network.swift

#### v0.9.7:

- Removed all targets
- Removed other unnecessary files
- Moved the network support to its own file (as far as possible).
- Added release tag

#### v0.9.6:

- Included extension for type String to easily create a SOURCE identifier from a #file string.
- JSON code returned by 'json' changed from a value to a valid hierarchy.
- Added ALL_NON_RECURSIVE target definition.
- Updated for changes in SwifterSockets.Transmit

#### v0.9.5:

- Added transfer of log entries to a TCP/IP destination and targetting of error messages.
- Renamed logfileRecordAtAndAboveLevel to fileRecordAtAndAboveLevel
- Added call-back logging

#### v0.9.4

- Added conveniance functions that add the "ID" parameter back in as hexadecimal output before the source.
- Note: v0.9.4 was never released into the public.

#### v0.9.3:
- Updated for Swift 2.0