# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- markdownlint-disable MD024 -->


## [2026-01-11]

### Changed

- Maintenance release



### Changed

- Updated Ansible Core to 2.20.1

## [2024-03-09]

### Changed

- Updated dependencies:
  - `dnspython` from `2.5.0` to `2.6.1`.
  - `crowdstrike-falconpy` from `1.4.0` to `1.4.0`.
  - `pytz` from `2023.4` to `2024.1`.
  - `netaddr` from `0.10.1` to `1.2.1`.
  - `pip` from `23.3.2` to `24.0`.
  - `python-dateutil` from `2.8.2` to `2.9.0.post0`.
- Updated Ansible version from `2.16.2` to `2.16.4`.

## [2024-02-01]

### Changed

- Updated dependencies:
  - `dnspython` from `2.4.2` to `2.5.0`.
  - `lxml` from `5.0.0` to `5.1.0`.
  - `netaddr` from `0.10.0` to `0.10.1`.
  - `pytz` from `2023.3.post1` to `2023.4`.
- Updated Alpine base image from `3.18.5` to `3.19.0`.

## [2024-01-02]

### Changed

- Updated dependencies:
  - `netaddr` from `0.9.0` to `0.10.0`.
  - `docker` from `6.1.3` to `7.0.0`.
  - `crowdstrike-falconpy` from `1.3.4` to `1.4.0`.
  - `pip` from `23.3.1` to `23.3.2`.
  - `lxml` from `4.9.3` to `5.0.0`.
- Updated Alpine base image from `3.18.5` to `3.19.0`.
- Added `--break-system-packages` option in pip installation to allow installing packages in externally managed
  environments.
- Updated Ansible version from `2.15.5` to `2.16.2`.

## [2023-12-01]

### Changed

- Updated dependencies:
  - `crowdstrike-falconpy` from `1.3.3` to `1.3.4`.
  - `wheel` from `0.41.3` to `0.42.0`.
  - `alpine` from `3.18.4` to `3.18.5`.

## [2023-11-28]

### Fixed

- Improved integration of `ansible-inventory` in the Dockerfile, including:
  - Addition of 3 lines.
  - Removal of 3 lines.
  - Changes primarily focus on copying and linking files related to `ansible-inventory`.

## [2023-11-09]

### Changed

- Added `falconpy` library to Docker requirements for CrowdStrike installation.

## [2023-11-01]

### Changed

- Updated dependencies:
  - `ansible` from `2.15.4` to `2.15.5`.
  - `cffi` from `1.15.1` to `1.16.0`.
  - `dnspython` from `2.3.0` to `2.4.2`.
  - `docker` from `6.0.1` to `6.1.3`.
  - Docker Actions:
    - `build-push-action` from `4` to `5`.
    - `login-action` from `2` to `3`.
    - `metadata-action` from `4` to `5`.
  - `lxml` from `4.9.2` to `4.9.3`.
  - `mitogen` from `0.3.3` to `0.3.4`.
  - `netaddr` from `0.8.0` to `0.9.0`.
  - `openshift` from `0.13.1` to `0.13.2`.
  - `pip` from `23.2.1` to `23.3.1`.
  - `wheel` from `0.41.2` to `0.41.3`.

## [2023-10-08]

### Changed

- Updated dependencies:
  - `alpine` from `3.17.1` to `3.18.4`.
  - `ansible` from `2.14.1` to `2.15.4`.
  - `pip` from `23.0` to `23.2.1`.
  - `pytz` from `2022.7.1` to `2023.3.post1`.
  - `wheel` from `0.38.4` to `0.41.2`.

## [2023-02-02]

### Changed

- Updated dependencies:
  - `alpine` from `3.17.0` to `3.17.1`.
  - `dnspython` from `2.2.1` to `2.3.0`.
  - Docker Actions:
    - `build-push-action` from `3` to `4`.
  - `lxml` from `4.9.1` to `4.9.2`.
  - `pip` from `22.3.1` to `23.0`.
  - `pytz` from `2022.6` to `2022.7.1`.

## [2022-12-10]

### Changed

- Updated dependencies:
  - `actions/checkout` from `1` to `3`.
  - `alpine` from `3.16.2` to `3.17.0`.
  - `ansible` from `2.12.4` to `2.14.1`.
  - `docker` from `6.0.0` to `6.0.1`.
  - Docker Actions:
    - `build-push-action` from `2` to `3`.
    - `login-action` from `1` to `2`.
    - `setup-buildx-action` from `1` to `2`.
    - `setup-qemu-action` from `1` to `2`.
  - `pip` from `22.2.2` to `22.3.1`.
  - `pytz` from `2022.2.1` to `2022.6`.
  - `wheel` from `0.37.1` to `0.38.4`.

## [2022-09-01]

### Changed

- Updated dependencies:
  - `pip` from `22.2.1` to `22.2.2`.
  - `alpine` from `3.16.1` to `3.16.2`.
  - `pytz` from `2022.1` to `2022.2.1`.
  - `docker` from `5.0.3` to `6.0.0`.

## [2022-07-28]

### Changed

- Updated dependencies:
  - `alpine` from `3.15.4` to `3.16.1`.
  - `cffi` from `1.15.0` to `1.15.1`.
  - `jmespath` from `1.0.0` to `1.0.1`.
  - `lxml` from `4.8.0` to `4.9.1`.
  - `mitogen` from `0.3.2` to `0.3.3`.
  - `pip` from `22.0.4` to `22.2.1`.

## [2022-05-07]

### Added

- Added `kustomize` version `4.5.4`.

### Changed

- Updated `pywinrm[credssp]` from `0.4.2` to `0.4.3`.

## [2022-04-08]

### Added

- Added `openssl` version `1.1.1n-r0`.

## [2022-04-01]

### Added

- Added `python-dateutil` version `2.8.2`.
- Added `pytz` version `2022.1`.

### Changed

- Updated dependencies:
  - `alpine` from `3.15.0` to `3.15.3`.
  - `ansible` from `2.12.2` to `2.12.4`.
  - `dnspython` from `2.2.0` to `2.2.1`.
  - `jmespath` from `0.10.0` to `1.0.0`.
  - `lxml` from `4.7.1` to `4.8.0`.
  - `openshift` from `0.12.1` to `0.13.1`.
  - `pip` from `22.0.3` to `22.0.4`.
  - `requests-credssp` from `1.3.0` to `2.0.0`.

## [2022-02-04]

### Changed

- Updated dependencies:
  - `ansible` from `2.12.0` to `2.12.2`.
  - `lxml` from `4.6.5` to `4.7.1`.
  - `wheel` from `0.37.0` to `0.37.1`.
  - `mitogen` from `0.3.0` to `0.3.2`.
  - `dnspython` from `2.1.0` to `2.2.0`.
  - `pip` from `21.3.1` to `22.0.3`.

## [2021-12-13]

### Changed

- Updated `lxml` from `4.6.4` to `4.6.5`.

## [2021-11-28]

### Added

- Added python packages:
  - `lxml`.
  - `docker`.
  - `jmespath`.

### Changed

- Updated `alpine` from `3.14.3` to `3.15.0`.

## [2021-11-18]

### Added

- Added python packages:
  - `openshift`.
  - `pyhelm`.

## [2021-11-15]

### Changed

- Updated dependencies:
  - `ansible` from `2.11.6` to `2.12.0`.
  - `requests-credssp` from `1.2.0` to `1.3.0`.
  - `pip` from `21.3` to `21.3.1`.
  - `mitogen` from `0.2.9` to `0.3.0`.
  - `alpine` from `3.14.2` to `3.14.3`.

## [2021-06-03]

### Added

- Added `rust` and `cargo` packages.

### Changed

- Updated dependencies:
  - `alpine` from `3.12.1` to `3.13.5`.
  - Multiple versions of `ansible`:
    - from `2.10.3` to `2.10.7`.
    - from `2.8.8.17` to `2.8.20`.
    - from `2.9.15` to `2.9.22`.
  - `cffi` from `1.14.3` to `1.14.5`.
  - `dnspython` from `2.0.0` to `2.1.0`.
  - `pip` from `20.2.4` to `21.1.2` (listed twice).
  - `pywinrm[credssp]` from `0.4.1` to `0.4.2`.

## [2020-11-09]

### Changed

- Updated dependencies:
  - `pip` from `20.2.3` to `20.2.4`.
  - `alpine` from `3.12.0` to `3.12.1`.
  - Multiple versions of `ansible`:
    - from `2.8.15` to `2.8.17`.
    - from `2.9.13` to `2.9.15`.
    - from `2.10.0` to `2.10.3`.

## [2020-10-03]

### Added

- Added `Ansible Version 2.10.0`.

### Changed

- Updated dependencies:
  - `pip` from `20.2.2` to `20.2.3`.
  - `cffi` from `1.14.2` to `1.14.3`.

## [2020-09-06]

### Added

- Added `dependabot.yml` file for the dependabot.

### Changed

- Updated `ansible` versions:
  - from `2.9.9` to `2.9.13`.
  - from `2.8.12` to `2.8.15`.

## [2020-09-05]

### Changed

- Updated dependencies:
  - `cffi` from `1.14.0` to `1.14.2`.
  - `requests-credssp` from `1.1.1` to `1.2.0`.
  - `pip` from `20.1.1` to `20.2.2`.
  - `dnspython` from `1.16.0` to `2.0.0`.
  - `netaddr` from `0.7.20` to `0.8.0`.

### Fixed

- Fixed the issue where the `rsync` package was not present in the container.

## [2020-07-13]

### Changed

- Updated `netaddr` from `0.7.19` to `0.7.20`.

## [2020-06-07]

### Added

- Added `py3-pip` dependency.

### Changed

- Updated dependencies:
  - `pip` from `20.1` to `20.1.1`.
  - `alpine` from `3.11.6` to `3.12.0`.

## [2020-05-14]

### Added

- Added `python package dnspython3`.

### Changed

- Updated to the latest Ansible versions.

## [2020-05-01]

### Changed

- Updated to the latest Ansible versions.
- Updated dependencies:
  - `alpine` from `3.11.3` to `3.11.6`.
  - `pip` from `20.0.2` to `20.1`.
- Changed publish job name.
- Changed action trigger event.

## [Initial Release]

- Initial release of the project.
