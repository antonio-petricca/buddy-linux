# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.2] - 2018-07-09

### Changed

- File **assets/dracut/20-buddy-linux.conf**.
- Fixed Ubiquity restored point.
- Moved to lazy umount (fix /target umount issue).

### Changed

- Fixed Dracut configuration files.

## [1.1.1] - 2018-05-30

### Changed

- Fixed default GRUB entry detection.
- GRUB defaults to latest Paragon entry, if present.

## [1.1.0] - 2018-05-28

### Added

- Added suggestion about NTFG-3G driver update.
- Added Dracut shutdown warning known issue.
- Added support for [Paragon Express NTFS driver](https://www.paragon-software.com/home/ntfs-linux-professional/).

## Changed

- Deprecated **README-EXPERTS.md**.

## Removed

- Removed support from NetConsole.
- Removed Recovery, not working with Dracut (you may use a Live USB to recover).

## [1.0.1] - 2018-05-21

- Published boot drive backup and restore scripts.

## [1.0.0] - 2018-05-19

### Changed

- Renamed account from **DareDevil73** to **antonio-petricca**.
- Renamed project from **linux-on-loopback-usb** to **buddy-linux**.

## [0.0.2] - 2018-05-18

### Added

- Change log.
- Installation script.
- Dracut support (default) for a safe shutdown process.

### Changed

- Lot of refactoring.
- Improved documentation.

## [0.0.1] - 2018-04-13

- First release.

[1.1.2]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.1...1.1.2
[1.1.1]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/antonio-petricca/buddy-linux/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/antonio-petricca/buddy-linux/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/antonio-petricca/buddy-linux/compare/0.0.2...1.0.0
[0.0.2]: https://github.com/antonio-petricca/buddy-linux/compare/0.0.1...0.0.2
[0.0.1]: https://github.com/antonio-petricca/buddy-linux/tree/0.0.1