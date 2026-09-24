#!/bin/bash
# Copies the subset of the GigaDevice GD32VW55x WiFi & BLE SDK that the Zephyr
# radio driver builds against, from a git checkout of the vendor repository:
#
#   ./import.sh <path to GD32VW55x_WiFi_BLE_SDK.git> <commit>
#
# Run from this directory (gd32vw55x/wifi_ble_sdk). Everything below MSDK,
# ROM-EXPORT and config is replaced by the vendor files; the README, this
# script and the Zephyr patches (separate commit) are kept.
set -e
REPO=$1
REV=$2
[ -d "$REPO" ] && [ -n "$REV" ] || { echo "usage: $0 <vendor repo> <commit>"; exit 1; }
cd "$(dirname "$0")"

# Whole directories: vendor layers the driver compiles or whose headers it
# needs as a set (the MAC/BLE interfaces, the mbedTLS copy the prebuilt
# supplicant was built against).
DIRS="
MSDK/wifi_manager
MSDK/util
MSDK/macsw
MSDK/blesw
MSDK/plf/riscv/NMSIS/DSP/Include
MSDK/mbedtls/mbedtls/include
MSDK/mbedtls/mbedtls/library
ROM-EXPORT/bootloader
ROM-EXPORT/halcomm
"
# Single files: platform sources the driver compiles and the headers they
# pull in. The peripheral library, the NMSIS core headers and the SoC
# header are NOT copied: the HAL carries them (gd32vw55x/standard_peripheral,
# gd32vw55x/riscv). hostap is not copied either: the supplicant is the
# prebuilt libwpas.a.
FILES="
MSDK/plf/src/dma/dma.c MSDK/plf/src/dma/dma.h
MSDK/plf/src/dsp.c MSDK/plf/src/dsp.h
MSDK/plf/src/gd32vw55x_platform.c MSDK/plf/src/gd32vw55x_platform.h
MSDK/plf/src/init_rom.c MSDK/plf/src/init_rom.h MSDK/plf/src/init_rom_symbol.c
MSDK/plf/src/nvds/nvds_flash.c MSDK/plf/src/nvds/nvds_flash.h MSDK/plf/src/nvds/nvds_type.h
MSDK/plf/src/plf_assert.c MSDK/plf/src/plf_assert.h
MSDK/plf/src/raw_flash/raw_flash_api.c MSDK/plf/src/raw_flash/raw_flash_api.h
MSDK/plf/src/rf/hal_rf.h MSDK/plf/src/rf/rfi.h MSDK/plf/src/rf/rf_spi.h
MSDK/plf/src/time/systime.c MSDK/plf/src/time/systime.h
MSDK/plf/src/trng/trng.c MSDK/plf/src/trng/trng.h
MSDK/plf/src/uart/log_uart.h MSDK/plf/src/uart/trace_uart.h MSDK/plf/src/uart/uart_config.h MSDK/plf/src/uart/uart.h
MSDK/plf/src/wakelock.c MSDK/plf/src/wakelock.h
MSDK/plf/riscv/gd32vw55x/gd32vw55x_it.c MSDK/plf/riscv/gd32vw55x/gd32vw55x_it.h
MSDK/plf/riscv/arch/arch.h MSDK/plf/riscv/arch/boot/boot.h MSDK/plf/riscv/arch/compiler/compiler.h MSDK/plf/riscv/arch/ll/ll.h
MSDK/ble/app/virtual_hci.c MSDK/ble/app/virtual_hci.h
MSDK/rtos/rtos_wrapper/wrapper_os.h MSDK/rtos/rtos_wrapper/wrapper_os_config.h
MSDK/mbedtls/mbedtls/LICENSE MSDK/mbedtls/mbedtls/tests/include/spe/crypto_spe.h
MSDK/wpa_supplicant/COPYING
config/config_gdm32.h config/platform_def.h
"

rm -rf MSDK ROM-EXPORT config
git -C "$REPO" archive "$REV" $DIRS $FILES | tar -x
# The vendor build files are not used (the Zephyr driver lists the sources)
find MSDK -type f \( -name CMakeLists.txt -o -name Makefile \) -delete
# Generated at the vendor's build, carries no license and is not used
rm -f MSDK/macsw/export/_build_version.h
# The vendor tree has CRLF line endings; the HAL is LF (see the top README).
find MSDK ROM-EXPORT config -type f \( -name '*.c' -o -name '*.h' -o -name COPYING -o -name LICENSE \) -exec sed -i 's/\r$//' {} +
echo "imported $(find MSDK ROM-EXPORT config -type f | wc -l) files from $REV"
