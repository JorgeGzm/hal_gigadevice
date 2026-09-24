# GD32VW55x Wi-Fi/BLE SDK

Source layers of the GigaDevice *GD32VW55x WiFi & BLE SDK* that the Zephyr
Wi-Fi/BLE driver (`zephyr/drivers/wifi/gdwifi`) builds and links against.

## Provenance

- Vendor repository: https://github.com/GigaDevice-GD32-MCU/GD32VW55x_WiFi_BLE_SDK
- Version: V1.0.3g, commit `945c6e28754f1bbdefb8bcd3049593fae8873bd5`
- The files are copied from that commit unchanged by `import.sh`. The
  changes the Zephyr build needs are applied on top by a separate commit of
  this repository ("patch the Wi-Fi/BLE SDK for Zephyr"), so they can be
  reviewed as a diff against the vendor release: guards (`GDWIFI_RTOS`,
  `GDWIFI_RTOS_NET`, `__ZEPHYR__`) that make the LPDS entry a no-op, keep
  power save off and skip the SDK lwIP when the OS brings its own network
  stack; a wait for the MAC hardware to be idle before connecting; and, in
  `config/platform_def.h`, the `CONFIG_BOARD` macro (the Zephyr Kconfig
  board name) and the fixed `CFG_WLAN_SUPPORT`/`CFG_BLE_SUPPORT` left to the
  driver build. Without the guards the vendor build is unchanged. The same changes are
  kept, for submission to GigaDevice, on the `port-v1.0.3g` branch of
  https://github.com/JorgeGzm/GD32VW55x_WiFi_BLE_SDK.

## Contents

Only what the driver compiles or includes, in the vendor's directory
layout:

- `MSDK/plf/src`: the platform sources the driver builds (platform
  bring-up, ROM init, DMA, NVDS, raw flash, TRNG, system time, wake locks,
  DSP glue, asserts) and the headers they pull in
- `MSDK/plf/riscv`: `gd32vw55x_it.c/.h` (the radio interrupt handlers),
  the `arch` headers and the NMSIS DSP headers of the prebuilt DSP library
- `MSDK/wifi_manager`, `MSDK/util`: the Wi-Fi control plane and utilities,
  compiled from source
- `MSDK/macsw`, `MSDK/blesw`: interface headers of the prebuilt MAC and
  BLE libraries
- `MSDK/ble/app/virtual_hci.*`: the virtual HCI transport used by the
  Zephyr Bluetooth host driver
- `MSDK/rtos/rtos_wrapper`: `wrapper_os.h` and its configuration (the OS
  API the libraries call; implemented by the Zephyr driver)
- `MSDK/mbedtls/mbedtls`: the mbedTLS 3.6 `include` and `library` the
  prebuilt supplicant was built against, plus its `LICENSE`
- `ROM-EXPORT`: the mask ROM API headers
- `config/config_gdm32.h` (the flash map) and `config/platform_def.h` (the
  platform selection: ASIC, RF type, crystal)
- `MSDK/wpa_supplicant/COPYING`: the hostap license, which the
  hostap-derived headers in `MSDK/wifi_manager/wpas` refer to

Not copied: the peripheral library, the NMSIS core headers and the SoC
header (the HAL carries them under `gd32vw55x/standard_peripheral` and
`gd32vw55x/riscv`), the hostap sources (the supplicant is the prebuilt
`libwpas.a`), the RTOS ports, lwIP, FatFS, the examples, the cloud SDKs,
the BLE application, the ROM symbol table, the generated
`macsw/export/_build_version.h`, the vendor build files, documentation,
tools and every binary.

## Updating

From a git checkout of the vendor repository:

    cd gd32vw55x/wifi_ble_sdk
    ./import.sh /path/to/GD32VW55x_WiFi_BLE_SDK <commit>

then reapply the Zephyr patch commit, update the blob URLs and checksums
in `zephyr/module.yml` and this file.

## Radio libraries

The prebuilt libraries are not in this tree. They are declared as blobs in
`zephyr/module.yml` at the root of this module and fetched from the vendor
repository, at the same commit, with:

    west blobs fetch hal_gigadevice

The Zephyr driver links them against an OS abstraction kept in source form.

## Licensing

The GigaDevice sources carry BSD-3-Clause headers. The hostap-derived
headers in `MSDK/wifi_manager/wpas` are BSD (`MSDK/wpa_supplicant/COPYING`),
`MSDK/util` carries cJSON under the MIT license (text in the files),
mbedTLS is Apache-2.0 OR GPL-2.0-or-later and is used under Apache-2.0
(`MSDK/mbedtls/mbedtls/LICENSE`), and the NMSIS DSP headers are
Apache-2.0. The binary libraries are distributed under the GigaDevice
software license agreement SLA-GD0012 (`zephyr/blobs/license.txt`).
