/*
 * Copyright (c) 2023, GigaDevice Semiconductor Inc.
 * Copyright (c) 2026 GZM Embedded
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Platform definition for the GD32VW55x vendor firmware library, reduced
 * to the ASIC/START-board configuration used by Zephyr.  The wireless
 * feature flags (CFG_WLAN_SUPPORT, CFG_BLE_SUPPORT, CFG_COEX) are NOT
 * defined here: they are injected per-library by the Wi-Fi/BLE build glue
 * so that plain peripheral builds do not drag radio configuration in.
 */

#ifndef _PLATFORM_DEF_H
#define _PLATFORM_DEF_H

#define PLATFORM_FPGA_32103_V7          1
#define PLATFORM_FPGA_32103_ULTRA       2
#define PLATFORM_ASIC_32103             103

/* platform type */
#define CONFIG_PLATFORM                 PLATFORM_ASIC_32103

#if CONFIG_PLATFORM >= PLATFORM_ASIC_32103
#define CONFIG_PLATFORM_ASIC
#else
#define CONFIG_PLATFORM_FPGA
#endif

/* board type.  CONFIG_BOARD itself is NOT defined here: the name collides
 * with the Zephyr Kconfig string of the same name.  The Wi-Fi/BLE build
 * glue defines CONFIG_BOARD=PLATFORM_BOARD_32VW55X_START privately for the
 * vendor radio sources that test it.
 */
#define PLATFORM_BOARD_32VW55X_START    1
#define PLATFORM_BOARD_32VW55X_EVAL     2
#define PLATFORM_BOARD_32VW55X_F527     3
#define PLATFORM_BOARD_32VW55X_SONIC    4

/* RF type */
#define RF_GDM32106                     1
#define RF_GDM32110                     2
#define RF_GDM32103                     3

#define CONFIG_RF_TYPE                  RF_GDM32103

/* CRYSTAL type */
#define CRYSTAL_26M                     1
#define CRYSTAL_40M                     2
#define CRYSTAL_48M                     3
#define PLATFORM_CRYSTAL                CRYSTAL_40M

#if defined(CFG_WLAN_SUPPORT) && defined(CFG_BLE_SUPPORT)
#define CFG_COEX
#endif

/* Flag indicating if NVDS FLASH feature is supported or not */
#define NVDS_FLASH_SUPPORT              1

#endif /* _PLATFORM_DEF_H */
