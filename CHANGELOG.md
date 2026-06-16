# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- markdownlint-disable MD024 -->


## [2026-06-16]

### Changed

- Updated Python dependencies:
  - boto3 1.43.28 → 1.43.29
  - botocore 1.43.28 → 1.43.29
  - google-auth 2.53.0 → 2.54.0


## [2026-06-15]

### Changed

- Updated Ansible Core version from 2.20.5 to 2.21.0.
- Updated Alpine version from 3.23.4 to 3.24.0.
- Updated Python dependencies:
  - pip 26.1.1 → 26.1.2
  - lxml 6.1.0 → 6.1.1
  - mitogen 0.3.47 → 0.3.49
  - cryptography 48.0.0 → 48.0.1
  - PyMySQL 1.1.3 → 1.2.0
  - boto3 1.43.9 → 1.43.28
  - botocore 1.43.9 → 1.43.28
  - google-cloud-compute 1.47.0 → 1.48.0
  - kubernetes 36.0.0 → 36.0.2
  - python-gitlab 8.3.0 → 8.4.0
  - opentelemetry-exporter-otlp 1.41.1 → 1.42.1
- Updated some package constraints in `Dockerfile`:
  - py3-pip version constraints updated from `<26.0.0` to `<27.0.0`
  - python3-dev version constraints updated from `<3.13.0` to `<3.15.0`
  - python version constraints updated from `<3.13.0` to `<3.15.0`
  - kubectl version constraints updated from `<1.35.0` to `<1.37.0`

## [2026-06-09]

### Changed

- Updated Ansible version from 2.20.4 to 2.20.5
- Updated Alpine version from 3.15 to 3.16
- Updated Python dependencies: boto3 1.19.23 → 1.19.24, botocore 1.22.23 → 1.22.24
- Removed unused dependency: requests 2.26.0


## [2026-06-02]

### Changed

- Updated Kubernetes integration: kubernetes 35.0.0 → 36.0.0


## [2026-05-19]

### Changed

- Updated Python dependencies:  
  - boto3 1.43.8 → 1.43.9  
  - botocore 1.43.8 → 1.43.9  
  - google-auth 2.52.0 → 2.53.0  

### Fixed

- No fixes applied.  

### Security

- No security updates.


## [2026-05-18]

### Changed

- Updated Ansible version to 2.20.5
- Updated Python dependencies:
  - requests 2.34.1 → 2.34.2
  - boto3 1.43.7 → 1.43.8
  - botocore 1.43.7 → 1.43.8


## [2026-05-17]

### Changed

- Updated Ansible version to 2.20.5
- Updated Python dependencies:
  - requests 2.34.0 → 2.34.1
  - boto3 1.43.6 → 1.43.7
  - botocore 1.43.6 → 1.43.7


## [2026-05-16]

### Changed

- Updated Python dependencies:
  - idna 3.14 → 3.15
  - pyvmomi 9.0.0.0 → 9.1.0.0
  
### Security

- Updated `idna` to version 3.15 to include security fixes.


## [2026-05-15]

### Changed

- Updated Python dependencies:
  - requests 2.33.1 → 2.34.0
  - pandas 3.0.2 → 3.0.3

### Fixed

- Updated requirements for specific libraries as part of maintenance.


## [2026-05-14]

### Changed

- Updated idna from 3.13 to 3.14

### Fixed

- Updated Ansible version to 2.20.5


## [2026-05-11]

### Changed

- Updated Python dependencies:
  - urllib3 2.6.3 → 2.7.0
  - boto3 1.43.5 → 1.43.6
  - botocore 1.43.5 → 1.43.6
  - google-auth 2.50.0 → 2.52.0

### Security

- Updated urllib3 to version 2.7.0 to address security vulnerabilities.


## [2026-05-10]

### Changed

- Updated Python dependencies:  
  - boto3 1.43.4 → 1.43.5  
  - botocore 1.43.4 → 1.43.5  

### Fixed

- Maintenance release


## [2026-05-09]

### Changed

- Updated Ansible Core version to 2.20.5
- Updated Python dependencies:
  - pip 26.1 → 26.1.1
  - boto3 1.43.2 → 1.43.4
  - botocore 1.43.2 → 1.43.4


## [2026-05-05]

### Changed

- Updated Python dependencies:  
  - boto3 1.43.1 → 1.43.2  
  - botocore 1.43.1 → 1.43.2  

### Fixed

- Fixed compatibility issues with updated boto3 and botocore versions.


## [2026-05-01]

### Changed

- Updated Ansible Core version: 2.20.4 → 2.20.5
- Updated Alpine version: 3.23.3 → 3.23.4
- Updated Python dependencies:
  - pip 26.0.1 → 26.1
  - wheel 0.46.3 → 0.47.0
  - lxml 6.0.2 → 6.1.0
  - crowdstrike-falconpy 1.6.1 → 1.6.2
  - mitogen 0.3.45 → 0.3.47
  - cryptography 46.0.7 → 47.0.0
  - idna 3.11 → 3.13
  - psycopg2-binary 2.9.11 → 2.9.12
  - PyMySQL 1.1.2 → 1.1.3
  - boto3 1.42.82 → 1.43.1
  - botocore 1.42.82 → 1.43.1
  - azure-mgmt-compute 37.2.0 → 38.0.0
  - google-auth 2.49.1 → 2.50.0
  - python-gitlab 8.2.0 → 8.3.0
  - opentelemetry-exporter-otlp 1.40.0 → 1.41.1
  - prometheus-client 0.24.1 → 0.25.0
  - invoke 2.2.1 → 3.0.3

### Security

- Updated `ca-certificates` version base: 20250619 → <20270000

## [2026-04-08]

### Changed

- Updated cryptography from version 46.0.6 to 46.0.7


## [2026-04-06]

### Changed

- Updated charset-normalizer from 3.4.6 to 3.4.7
- Updated boto3 from 1.42.81 to 1.42.82
- Updated botocore from 1.42.81 to 1.42.82


## [2026-04-05]

### Changed

- Updated Python dependencies:  
  - boto3 1.42.80 → 1.42.81  
  - botocore 1.42.80 → 1.42.81  

### Fixed

- Ansible version remains at 2.20.4.


## [2026-04-04]

### Changed

- Updated Ansible version: 2.20.4
- Updated Python dependencies:  
  - boto3 1.42.79 → 1.42.80  
  - botocore 1.42.79 → 1.42.80  
  - pandas 3.0.1 → 3.0.2


## [2026-04-03]

### Changed

- Updated Python dependencies:  
  - boto3 1.42.78 → 1.42.79  
  - botocore 1.42.78 → 1.42.79  
  - google-cloud-compute 1.46.0 → 1.47.0  


## [2026-04-02]

### Changed

- Updated Python dependencies: 
  - requests 2.33.0 → 2.33.1
  - mitogen 0.3.44 → 0.3.45
  
### Fixed

- Updated pytz version to 2026.1.post1.


## [2026-03-31]

### Changed

- Updated Python dependencies:  
  - boto3 1.42.77 → 1.42.78  
  - botocore 1.42.77 → 1.42.78  
  - python-gitlab 8.1.0 → 8.2.0  
- Ansible version updated to 2.20.4


## [2026-03-30]

### Changed

- Updated Python dependencies:  
  - boto3 1.42.76 → 1.42.77  
  - botocore 1.42.76 → 1.42.77  

### Fixed

- Updated Ansible Core version from 2.20.4 to 2.20.4 (no changes to the version, included for completeness).


## [2026-03-29]

### Changed

- Updated Python dependencies:
  - tomli 2.4.0 → 2.4.1
  - cryptography 46.0.5 → 46.0.6
  - boto3 1.42.75 → 1.42.76
  - botocore 1.42.75 → 1.42.76

### Security

- Upgraded cryptography to 46.0.6 to address security vulnerabilities.

## [2026-03-26]

### Changed

- Updated Python dependencies: requests 2.32.5 → 2.33.0
- Current Ansible version: 2.20.4


## [2026-03-25]

### Changed

- Ansible Core version updated from 2.20.3 to 2.20.4
- Updated Python dependencies:
  - crowdstrike-falconpy 1.6.0 → 1.6.1
  - mitogen 0.3.43 → 0.3.44
  - charset-normalizer 3.4.4 → 3.4.6
  - redis 7.2.1 → 7.4.0
  - boto3 1.42.62 → 1.42.75
  - botocore 1.42.62 → 1.42.75
  - azure-identity 1.25.2 → 1.25.3
  - google-cloud-compute 1.44.0 → 1.46.0
  - google-auth 2.48.0 → 2.49.1
  - croniter 6.0.0 → 6.2.2

## [2026-03-08]

### Changed

- Updated Ansible version to 2.20.3
- Updated Python dependencies:
  - pytz 2025.2 → 2026.1.post1
  - mitogen 0.3.42 → 0.3.43
  - redis 7.1.1 → 7.2.1
  - boto3 1.42.58 → 1.42.62
  - botocore 1.42.58 → 1.42.62
  - azure-mgmt-network 30.1.0 → 30.2.0
  - google-cloud-compute 1.43.0 → 1.44.0
  - python-gitlab 8.0.0 → 8.1.0
  - opentelemetry-exporter-otlp 1.39.1 → 1.40.0
- Updated urllib3 version: 2.3.0 → 2.6.3


## [2026-03-02]

### Changed

- Updated Ansible Core version: 2.20.2 → 2.20.3
- Updated Python dependencies:
  - mitogen 0.3.41 → 0.3.42
  - boto3 1.42.53 → 1.42.58
  - botocore 1.42.53 → 1.42.58


## [2026-02-23]

### Changed

- Updated Python dependencies:
  - boto3 1.42.48 → 1.42.53
  - botocore 1.42.48 → 1.42.53
  - pandas 3.0.0 → 3.0.1

### Fixed

- No fixed issues reported.


## [2026-02-16]

### Changed

- Updated Ansible version to 2.20.2
- Updated Python dependencies:
  - mitogen 0.3.40 → 0.3.41
  - redis 7.1.0 → 7.1.1
  - boto3 1.42.43 → 1.42.48
  - botocore 1.42.43 → 1.42.48
  - azure-identity 1.25.1 → 1.25.2


## [2026-02-11]

### Changed

- Updated Python dependency: cryptography 46.0.4 → 46.0.5

### Security

- Updated cryptography to version 46.0.5 to address security vulnerabilities.


## [2026-02-09]

### Changed

- Updated Python dependencies: 
  - boto3 1.42.42 → 1.42.43
  - botocore 1.42.42 → 1.42.43
- Updated pip version: 26.0 → 26.0.1


## [2026-02-04]

### Changed

- Updated Alpine base image from `3.23.2` to `3.23.3`.
- Updated Ansible core version from `2.20.1` to `2.20.2`.
- Updated Python dependencies:
  - pip: `25.3` → `26.0`
  - jmespath: `1.0.1` → `1.1.0`
  - mitogen: `0.3.37` → `0.3.40`
  - cryptography: `46.0.3` → `46.0.4`
  - boto3: `1.42.33` → `1.42.42`
  - botocore: `1.42.33` → `1.42.42`
  - azure-mgmt-compute: `37.1.0` → `37.2.0`
  - google-cloud-compute: `1.41.0` → `1.43.0`
  - google-auth: `2.47.0` → `2.48.0`
  - kubernetes: `34.1.0` → `35.0.0`
  - python-gitlab: `7.1.0` → `8.0.0`
  - prometheus-client: `0.23.1` → `0.24.1`
  - pandas: `2.3.3` → `3.0.0`

## [2026-01-26]

### Changed

- Updated Ansible Core to version 2.20.1.
- Updated Python dependencies:
  - boto3 1.42.29 → 1.42.33
  - botocore 1.42.29 → 1.42.33
- Updated wheel from version 0.46.2 to 0.46.3.


## [2026-01-22]

### Changed

- Updated `wheel` from version `0.45.1` to `0.46.2`


## [2026-01-19]

### Changed

- Updated Python dependencies: 
  - boto3 1.42.25 → 1.42.29 
  - botocore 1.42.25 → 1.42.29

## [2026-01-11]

### Changed

- Updated Ansible version to 2.20.1.
- Updated Alpine packages:
  - Removed redundant `apk update` command in the Dockerfile to optimize image size.
- Updated Python dependencies:
  - tomli 2.3.0 → 2.4.0
  - boto3 1.42.24 → 1.42.25
  - botocore 1.42.24 → 1.42.25
  - google-cloud-compute 1.40.0 → 1.41.0

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
