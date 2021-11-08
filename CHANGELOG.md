# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### None...

## [1.2.1]

- Improved script `/sbin/update-dracut` options.
- Removed support for old Paragon UFSD driver (avoid **dracut** build errors).
- Updated script `boot-drive-backup`, for performance reason, now generates `tar.gz` in place of `tar.xz`.

## [1.2.0]

- Added support for Paragon NTFS3 mainline driver.

## [1.1.12]

### Changed

- Removed to the **update-grub** script the *--all* switch.

## [1.1.11]

### Changed

- Added to the **update-grub** script the *--all* switch.
- Fixed help on **install** script.
- Updated **install** script due to the previous changes.

### Removed

- Removed from to the **update-grub** script the *--current-only* switch.

## [1.1.10]

### Changed

- Added to the **update-grub** script the *--current-only* switch.
- 
## [1.1.9]

### Changed

- Updated GRUB entry description for Paragon driver.

## [1.1.8]

### Added

- Parameter **boot-device-grub-index**.

### Changed

- Fixed **CHANGELOG.md** hyperlinks.
- Message prompts now want ENTER to accept you choice.
- Updated **README.md**.

## [1.1.7]

### Added

- Enabled [ZSwap](https://wiki.archlinux.org/index.php/Zswap) for default.

## [1.1.6]

### Changed

- Added device, backup file and mount point check on script **boot-drive-restore**.

## [1.1.5] - 2018-08-14

### Added

- Print target device information before restoring boot device by script **boot-drive-restore**.

### Changed

- Fixed missing execution permission on script **update-dracut**.

## [1.1.4] - 2018-08-06

### Changed

- Fixed maybe missing grub default configuration folder for Ubuntu 18.04.

## [1.1.3] - 2018-07-12

### Changed

- Added GRUB_DEFAULT commenting.
- Fixed Dracut / LVM [configuration file](https://github.com/antonio-petricca/buddy-linux/issues/2).

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
- Added support for [Paragon Express NTFS driver](https://github.com/antonio-petricca/paragon-ufsd-ntfs-driver-porting).

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

[Unreleased]: https://github.com/antonio-petricca/buddy-linux/tree/develop
[1.2.1]: https://github.com/antonio-petricca/buddy-linux/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.12...1.2.0
[1.1.12]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.11...1.1.12
[1.1.11]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.10...1.1.11
[1.1.10]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.9...1.1.10
[1.1.9]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.8...1.1.9
[1.1.8]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.7...1.1.8
[1.1.7]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.6...1.1.7
[1.1.6]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.5...1.1.6
[1.1.5]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.4...1.1.5
[1.1.4]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.3...1.1.4
[1.1.3]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.2...1.1.3
[1.1.2]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.1...1.1.2
[1.1.1]: https://github.com/antonio-petricca/buddy-linux/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/antonio-petricca/buddy-linux/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/antonio-petricca/buddy-linux/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/antonio-petricca/buddy-linux/compare/0.0.2...1.0.0
[0.0.2]: https://github.com/antonio-petricca/buddy-linux/compare/0.0.1...0.0.2
[0.0.1]: https://github.com/antonio-petricca/buddy-linux/tree/0.0.1
