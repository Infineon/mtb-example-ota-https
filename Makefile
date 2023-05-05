################################################################################
# \file Makefile
# \version 1.0
#
# \brief
# Top-level application make file.
#
################################################################################
# \copyright
# Copyright 2018-2023, Cypress Semiconductor Corporation (an Infineon company)
# SPDX-License-Identifier: Apache-2.0
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################


################################################################################
# Basic Configuration
################################################################################

# Type of ModusToolbox Makefile Options include:
#
# COMBINED    -- Top Level Makefile usually for single standalone application
# APPLICATION -- Top Level Makefile usually for multi project application
# PROJECT     -- Project Makefile under Application
#
MTB_TYPE=COMBINED

# Target board/hardware (BSP).
# To change the target, it is recommended to use the Library manager
# ('make library-manager' from command line), which will also update Eclipse IDE launch
# configurations.
TARGET=CY8CPROTO-062-4343W

# Core processor
CORE?=CM4

# Name of application (used to derive name of final linked file).
#
# If APPNAME is edited, ensure to update or regenerate launch
# configurations for your IDE.
APPNAME=mtb-example-ota-https

# Name of toolchain to use. Options include:
#
# GCC_ARM -- GCC provided with ModusToolbox software
# ARM     -- ARM Compiler (must be installed separately)
# IAR     -- IAR Compiler (must be installed separately)
#
# See also: CY_COMPILER_PATH below
TOOLCHAIN=GCC_ARM

# Default build configuration. Options include:
#
# Debug -- build with minimal optimizations, focus on debugging.
# Release -- build with full optimizations
# Custom -- build with custom configuration, set the optimization flag in CFLAGS
#
# If CONFIG is manually edited, ensure to update or regenerate launch configurations
# for your IDE.
CONFIG=Debug

# If set to "true" or "1", display full command-lines when building.
VERBOSE=


################################################################################
# Advanced Configuration
################################################################################

# Enable optional code that is ordinarily disabled by default.
#
# Available components depend on the specific targeted hardware and firmware
# in use. In general, if you have
#
#    COMPONENTS=foo bar
#
# ... then code in directories named COMPONENT_foo and COMPONENT_bar will be
# added to the build
#
COMPONENTS=FREERTOS LWIP MBEDTLS SECURE_SOCKETS OTA_HTTP

# Like COMPONENTS, but disable optional code that was enabled by default.
DISABLE_COMPONENTS=

# By default the build system automatically looks in the Makefile's directory
# tree for source code and builds it. The SOURCES variable can be used to
# manually add source code to the build process from a location not searched
# by default, or otherwise not found by the build system.
SOURCES=

# Like SOURCES, but for include directories. Value should be paths to
# directories (without a leading -I).
INCLUDES=./configs

# Custom configuration of mbedtls library.
MBEDTLSFLAGS = MBEDTLS_USER_CONFIG_FILE='"configs/mbedtls_user_config.h"'

# Add additional defines to the build process (without a leading -D).
DEFINES=$(MBEDTLSFLAGS) CYBSP_WIFI_CAPABLE CY_RETARGET_IO_CONVERT_LF_TO_CRLF 
DEFINES+=CY_RTOS_AWARE
# Set user agent name in all request headers with the specified name
DEFINES += HTTP_USER_AGENT_VALUE="\"anycloud-http-client\""
# Configure response header maximum length with the specified value - HTTP
DEFINES += HTTP_MAX_RESPONSE_HEADERS_SIZE_BYTES=2048
# Disable custom config header file
DEFINES += HTTP_DO_NOT_USE_CUSTOM_CONFIG

# CY8CPROTO-062-4343W board shares the same GPIO for the user button (USER BTN1)
# and the CYW4343W host wake up pin. Since this example can use the GPIO for  
# interfacing with the user button, the SDIO interrupt to wake up the host is
# disabled by setting CY_WIFI_HOST_WAKE_SW_FORCE to '0'.
# 
# If you want the host wake up feature on CY8CPROTO-062-4343W board, change the GPIO pin 
# for USER BTN in design/hardware & comment the below DEFINES line. For other
# targets commenting the below DEFINES line is sufficient.
DEFINES+=CY_WIFI_HOST_WAKE_SW_FORCE=0

# Select softfp or hardfp floating point. Default is softfp.
VFP_SELECT=hardfp

# Additional / custom C compiler flags.
#
# NOTE: Includes and defines should use the INCLUDES and DEFINES variable
# above.
CFLAGS=

# Additional / custom C++ compiler flags.
#
# NOTE: Includes and defines should use the INCLUDES and DEFINES variable
# above.
CXXFLAGS=

# Additional / custom assembler flags.
#
# NOTE: Includes and defines should use the INCLUDES and DEFINES variable
# above.
ASFLAGS=

# Additional / custom linker flags.
ifeq ($(TOOLCHAIN),GCC_ARM)
LDFLAGS=-Wl,--undefined=uxTopUsedPriority
else
ifeq ($(TOOLCHAIN),IAR)
LDFLAGS=--keep uxTopUsedPriority
else
ifeq ($(TOOLCHAIN),ARM)
LDFLAGS=--undefined=uxTopUsedPriority
else
LDFLAGS=
endif
endif
endif

# Additional / custom libraries to link in to the application.
LDLIBS=

# Path to the linker script to use (if empty, use the default linker script).
LINKER_SCRIPT=

# Custom pre-build commands to run.
PREBUILD=

# Custom post-build commands to run.
POSTBUILD=

###############################################################################
#
# OTA Setup
#
###############################################################################

# Set to 1 to add OTA defines, sources, and libraries (must be used with MCUBoot)
# NOTE: Extra code must be called from your app to initialize the OTA middleware.
OTA_SUPPORT=1

# HTTP Support
OTA_HTTP_SUPPORT=1
OTA_MQTT_SUPPORT=0
OTA_BT_SUPPORT=0

# Component for adding platform-specific code
# ex: source/port_support/mcuboot/COMPONENT_OTA_PSOC_062/flash_qspi/flash_qspi.c
COMPONENTS+=OTA_PSOC_062

# Set Platform type (added to defines and used when finding the linker script)
# Ex: PSOC_062_2M, PSOC_062_1M, PSOC_062_512K
# Only one of the following two if conditions will be true
OTA_PLATFORM=$(if $(filter PSOC6_02,$(DEVICE_COMPONENTS)),PSOC_062_2M,$(if $(filter PSOC6_03,$(DEVICE_COMPONENTS)),PSOC_062_512K))

# Only one of the following two if conditions will be true
OTA_FLASH_MAP=$(if $(filter PSOC6_02,$(DEVICE_COMPONENTS)),\
                   $(SEARCH_ota-update)/configs/flashmap/psoc62_2m_ext_swap_single.json,\
                   $(if $(filter PSOC6_03,$(DEVICE_COMPONENTS)),\
                        $(SEARCH_ota-update)/configs/flashmap/psoc62_512k_xip_swap_single.json))

# Change the version here or over-ride by setting an environment variable
# before building the application.
#
# export APP_VERSION_MAJOR=2
#
OTA_APP_VERSION_MAJOR?=1
OTA_APP_VERSION_MINOR?=0
OTA_APP_VERSION_BUILD?=0

###############################################################################
#
# OTA Functionality support
#
###############################################################################
ifeq ($(OTA_SUPPORT),1)

    # Build location local to this root directory.
    CY_BUILD_LOC:=./build
    
    # MCUBootApp header is added during signing step in POSTBUILD (sign_script.bash)
    MCUBOOT_HEADER_SIZE=0x400
    
    # Internal and external flash erased values used during signing step in POSTBUILD (sign_script.bash)
    CY_INTERNAL_FLASH_ERASE_VALUE=0x00
    CY_EXTERNAL_FLASH_ERASE_VALUE=0xFF
    
    # Add OTA_PLATFORM in DEFINES for platform-specific code
    # ex: source/port_support/mcuboot/COMPONENT_OTA_PSOC_062/flash_qspi/flash_qspi.c
    DEFINES+=$(OTA_PLATFORM)

    # for use when running flashmap.py
    FLASHMAP_PLATFORM=$(OTA_PLATFORM)

    FLASHMAP_PYTHON_SCRIPT=flashmap.py
    flash_map_mk_exists=$(shell if [ -s "flashmap.mk" ]; then echo "success"; fi )
    ifneq ($(flash_map_mk_exists),)
        $(info include flashmap.mk)
        include ./flashmap.mk
    endif # flash_map_mk_exists

    ############################
    # IF FLASH_MAP sets USE_XIP,
    #    we are executing code
    #    from external flash
    ############################

    ifeq ($(USE_XIP),1)

        # We need to set this flag for executing code from external flash
        CY_RUN_CODE_FROM_XIP=1

        # If code resides in external flash, we must support external flash.
        USE_EXTERNAL_FLASH=1

        # When running from external flash
        # Signal to /source/port_support/serial_flash/ota_serial_flash.c
        # That we need to turn off XIP and enter critical section when accessing SMIF.
        #  NOTE: CYW920829M2EVB-01 does not need this.
        CY_XIP_SMIF_MODE_CHANGE=1
    
        # Since we are running hybrid (some in RAM, some in External FLash),
        #   we need to override the WEAK functions in CYHAL
        DEFINES+=CYHAL_DISABLE_WEAK_FUNC_IMPL=1
    
    endif # USE_XIP

    ifeq ($(FLASH_AREA_IMG_1_SECONDARY_DEV_ID),FLASH_DEVICE_INTERNAL_FLASH)
        FLASH_ERASE_SECONDARY_SLOT_VALUE= $(CY_INTERNAL_FLASH_ERASE_VALUE)
    else
        FLASH_ERASE_SECONDARY_SLOT_VALUE= $(CY_EXTERNAL_FLASH_ERASE_VALUE)
    endif # SECONDARY_DEV_ID

    ###################################
    # Add OTA defines to build
    ###################################
    DEFINES+=\
        OTA_SUPPORT=1 \
        APP_VERSION_MAJOR=$(OTA_APP_VERSION_MAJOR)\
        APP_VERSION_MINOR=$(OTA_APP_VERSION_MINOR)\
        APP_VERSION_BUILD=$(OTA_APP_VERSION_BUILD)
    
    ###################################
    # The Defines from the flashmap.mk
    ###################################
    DEFINES+=\
        MCUBOOT_MAX_IMG_SECTORS=$(MCUBOOT_MAX_IMG_SECTORS)\
        MCUBOOT_IMAGE_NUMBER=$(MCUBOOT_IMAGE_NUMBER)\
        FLASH_AREA_BOOTLOADER_DEV_ID="$(FLASH_AREA_BOOTLOADER_DEV_ID)"\
        FLASH_AREA_BOOTLOADER_START=$(FLASH_AREA_BOOTLOADER_START)\
        FLASH_AREA_BOOTLOADER_SIZE=$(FLASH_AREA_BOOTLOADER_SIZE)\
        FLASH_AREA_IMG_1_PRIMARY_DEV_ID="$(FLASH_AREA_IMG_1_PRIMARY_DEV_ID)"\
        FLASH_AREA_IMG_1_PRIMARY_START=$(FLASH_AREA_IMG_1_PRIMARY_START) \
        FLASH_AREA_IMG_1_PRIMARY_SIZE=$(FLASH_AREA_IMG_1_PRIMARY_SIZE) \
        FLASH_AREA_IMG_1_SECONDARY_DEV_ID="$(FLASH_AREA_IMG_1_SECONDARY_DEV_ID)"\
        FLASH_AREA_IMG_1_SECONDARY_START=$(FLASH_AREA_IMG_1_SECONDARY_START) \
        FLASH_AREA_IMG_1_SECONDARY_SIZE=$(FLASH_AREA_IMG_1_SECONDARY_SIZE)

    ifneq ($(FLASH_AREA_IMAGE_SWAP_STATUS_DEV_ID),)
        DEFINES+=\
            FLASH_AREA_IMAGE_SWAP_STATUS_DEV_ID="$(FLASH_AREA_IMAGE_SWAP_STATUS_DEV_ID)"\
            FLASH_AREA_IMAGE_SWAP_STATUS_START=$(FLASH_AREA_IMAGE_SWAP_STATUS_START)\
            FLASH_AREA_IMAGE_SWAP_STATUS_SIZE=$(FLASH_AREA_IMAGE_SWAP_STATUS_SIZE)
    endif

    ifneq ($(FLASH_AREA_IMAGE_SCRATCH_DEV_ID),)
        DEFINES+=\
            FLASH_AREA_IMAGE_SCRATCH_DEV_ID="$(FLASH_AREA_IMAGE_SCRATCH_DEV_ID)"\
            FLASH_AREA_IMAGE_SCRATCH_START=$(FLASH_AREA_IMAGE_SCRATCH_START)\
            FLASH_AREA_IMAGE_SCRATCH_SIZE=$(FLASH_AREA_IMAGE_SCRATCH_SIZE)
    endif

    ifeq ($(USE_EXTERNAL_FLASH),1)
        DEFINES+=OTA_USE_EXTERNAL_FLASH=1
    endif
    
    ifeq ($(CY_RUN_CODE_FROM_XIP),1)
        DEFINES+=CY_RUN_CODE_FROM_XIP=1
    endif
    
    ifeq ($(CY_XIP_SMIF_MODE_CHANGE),1)
        DEFINES+=CY_XIP_SMIF_MODE_CHANGE=1
    endif

    # This section needs to be before finding LINKER_SCRIPT_WILDCARD as we need the extension defined
    ifeq ($(TOOLCHAIN),GCC_ARM)
        CY_ELF_TO_HEX=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-objcopy
        CY_ELF_TO_HEX_OPTIONS="-O ihex"
        CY_ELF_TO_HEX_FILE_ORDER="elf_first"
        CY_TOOLCHAIN=GCC
        CY_TOOLCHAIN_LS_EXT=ld
        LDFLAGS+="-Wl,--defsym,MCUBOOT_HEADER_SIZE=$(MCUBOOT_HEADER_SIZE),--defsym,FLASH_AREA_IMG_1_PRIMARY_START=$(FLASH_AREA_IMG_1_PRIMARY_START),--defsym,FLASH_AREA_IMG_1_PRIMARY_SIZE=$(FLASH_AREA_IMG_1_PRIMARY_SIZE)"
    else
    ifeq ($(TOOLCHAIN),IAR)
        CY_ELF_TO_HEX=$(MTB_TOOLCHAIN_IAR__BASE_DIR)/bin/ielftool
        CY_ELF_TO_HEX_OPTIONS="--ihex"
        CY_ELF_TO_HEX_FILE_ORDER="elf_first"
        CY_TOOLCHAIN=$(TOOLCHAIN)
        CY_TOOLCHAIN_LS_EXT=icf
        DEFINES+=CY_INIT_CODECOPY_ENABLE
        LDFLAGS+=--config_def MCUBOOT_HEADER_SIZE=$(MCUBOOT_HEADER_SIZE) --config_def FLASH_AREA_IMG_1_PRIMARY_START=$(FLASH_AREA_IMG_1_PRIMARY_START) --config_def FLASH_AREA_IMG_1_PRIMARY_SIZE=$(FLASH_AREA_IMG_1_PRIMARY_SIZE)
    else
    ifeq ($(TOOLCHAIN),ARM)
        CY_ELF_TO_HEX=$(MTB_TOOLCHAIN_ARM__BASE_DIR)/bin/fromelf
        CY_ELF_TO_HEX_OPTIONS="--i32 --output"
        CY_ELF_TO_HEX_FILE_ORDER="hex_first"
        CY_TOOLCHAIN=GCC
        CY_TOOLCHAIN_LS_EXT=sct
        LDFLAGS+=--pd=-DMCUBOOT_HEADER_SIZE=$(MCUBOOT_HEADER_SIZE) --pd=-DFLASH_AREA_IMG_1_PRIMARY_START=$(FLASH_AREA_IMG_1_PRIMARY_START) --pd=-DFLASH_AREA_IMG_1_PRIMARY_SIZE=$(FLASH_AREA_IMG_1_PRIMARY_SIZE)
    else
        $(error Must define toolchain ! GCC_ARM, ARM, or IAR)
    endif #ARM
    endif #IAR
    endif #GCC_ARM
    
    ifeq ($(CY_RUN_CODE_FROM_XIP),1)
        OTA_LINKER_SCRIPT_TYPE=_ota_xip
    else
        OTA_LINKER_SCRIPT_TYPE=_ota_int
    endif

    # Find Linker Script using wildcard
    # Directory within ota-upgrade library
    LINKER_SCRIPT=$(wildcard $(SEARCH_ota-update)/platforms/$(OTA_PLATFORM)/linker_scripts/COMPONENT_$(CORE)/TOOLCHAIN_$(TOOLCHAIN)/ota/*$(OTA_LINKER_SCRIPT_TYPE).$(CY_TOOLCHAIN_LS_EXT))
                                   
    ###################################################################################################
    # OTA POST BUILD scripting
    ###################################################################################################
    
    ######################################
    # Build Location / Output directory
    ######################################
    
    # output directory for use in the sign_script.bash
    OUTPUT_FILE_PATH:=$(CY_BUILD_LOC)/$(TARGET)/$(CONFIG)
    
    CY_HEX_TO_BIN="$(MTB_TOOLCHAIN_GCC_ARM__OBJCOPY)"
    APP_BUILD_VERSION=$(OTA_APP_VERSION_MAJOR).$(OTA_APP_VERSION_MINOR).$(OTA_APP_VERSION_BUILD)
    
    # MCUBoot flash support location
    MCUBOOT_DIR=$(SEARCH_ota-update)/source/port_support/mcuboot
    IMGTOOL_SCRIPT_NAME=imgtool/imgtool.py
    MCUBOOT_SCRIPT_FILE_DIR=$(MCUBOOT_DIR)
    MCUBOOT_KEY_DIR=$(MCUBOOT_DIR)/keys
    MCUBOOT_KEY_FILE=cypress-test-ec-p256.pem
    SIGN_SCRIPT_FILE_PATH=$(SEARCH_ota-update)/scripts/sign_script.bash
    
    # Signing is disabled by default
    # Use "create" for PSoC 062 instead of "sign", and no key path (use a space " " for keypath to keep batch happy)
    # MCUBoot must also be modified to skip checking the signature, see README for more details.
    # For signing, use "sign" and key path:
    # IMGTOOL_COMMAND_ARG=sign
    # CY_SIGNING_KEY_ARG="-k $(MCUBOOT_KEY_DIR)/$(MCUBOOT_KEY_FILE)"
    IMGTOOL_COMMAND_ARG=create
    CY_SIGNING_KEY_ARG=" "

    POSTBUILD=$(SIGN_SCRIPT_FILE_PATH) $(OUTPUT_FILE_PATH) $(APPNAME) $(CY_PYTHON_PATH)\
              $(CY_ELF_TO_HEX) $(CY_ELF_TO_HEX_OPTIONS) $(CY_ELF_TO_HEX_FILE_ORDER)\
              $(MCUBOOT_SCRIPT_FILE_DIR) $(IMGTOOL_SCRIPT_NAME) $(IMGTOOL_COMMAND_ARG) $(FLASH_ERASE_SECONDARY_SLOT_VALUE) $(MCUBOOT_HEADER_SIZE)\
              $(MCUBOOT_MAX_IMG_SECTORS) $(APP_BUILD_VERSION) $(FLASH_AREA_IMG_1_PRIMARY_START) $(FLASH_AREA_IMG_1_PRIMARY_SIZE)\
              $(CY_HEX_TO_BIN) $(CY_SIGNING_KEY_ARG)
endif # OTA_SUPPORT

################################################################################
# Paths
################################################################################

# Relative path to the project directory (default is the Makefile's directory).
#
# This controls where automatic source code discovery looks for code.
CY_APP_PATH=

# Relative path to the shared repo location.
#
# All .mtb files have the format, <URI>#<COMMIT>#<LOCATION>. If the <LOCATION> field
# begins with $$ASSET_REPO$$, then the repo is deposited in the path specified by
# the CY_GETLIBS_SHARED_PATH variable. The default location is one directory level
# above the current app directory.
# This is used with CY_GETLIBS_SHARED_NAME variable, which specifies the directory name.
CY_GETLIBS_SHARED_PATH=../

# Directory name of the shared repo location.
#
CY_GETLIBS_SHARED_NAME=mtb_shared

# Absolute path to the compiler's "bin" directory. The variable name depends on the 
# toolchain used for the build. Refer to the ModusToolbox user guide to get the correct
# variable name for the toolchain used in your build.
# 
# The default depends on the selected TOOLCHAIN (GCC_ARM uses the ModusToolbox
# software provided compiler by default).
CY_COMPILER_GCC_ARM_DIR=


# Locate ModusToolbox helper tools folders in default installation
# locations for Windows, Linux, and macOS.
CY_WIN_HOME=$(subst \,/,$(USERPROFILE))
CY_TOOLS_PATHS ?= $(wildcard \
    $(CY_WIN_HOME)/ModusToolbox/tools_* \
    $(HOME)/ModusToolbox/tools_* \
    /Applications/ModusToolbox/tools_*)

# If you install ModusToolbox software in a custom location, add the path to its
# "tools_X.Y" folder (where X and Y are the version number of the tools
# folder). Make sure you use forward slashes.
CY_TOOLS_PATHS+=

# Default to the newest installed tools folder, or the users override (if it's
# found).
CY_TOOLS_DIR=$(lastword $(sort $(wildcard $(CY_TOOLS_PATHS))))

ifeq ($(CY_TOOLS_DIR),)
$(error Unable to find any of the available CY_TOOLS_PATHS -- $(CY_TOOLS_PATHS). On Windows, use forward slashes.)
endif

$(info Tools Directory: $(CY_TOOLS_DIR))

include $(CY_TOOLS_DIR)/make/start.mk


###############################################################################
#
# OTA flashmap parser must be run after start.mk so that libs/mtb.mk is valid
#
###############################################################################

ifeq ($(OTA_SUPPORT),1)
#
# Only when we are in the correct build pass
#
    ifneq ($(MAKECMDGOALS),getlibs)
    ifneq ($(MAKECMDGOALS),get_app_info)
    ifneq ($(MAKECMDGOALS),printlibs)
    ifneq ($(FLASHMAP_PYTHON_SCRIPT),)
    ifneq ($(OTA_FLASH_MAP),)
    ifeq ($(CY_PYTHON_PATH),)
        CY_PYTHON_PATH=$(shell which python)
    endif
        $(info "flashmap.py $(CY_PYTHON_PATH) $(SEARCH_ota-update)/scripts/$(FLASHMAP_PYTHON_SCRIPT) -p $(FLASHMAP_PLATFORM) -i $(OTA_FLASH_MAP) > flashmap.mk")
        $(shell $(CY_PYTHON_PATH) $(SEARCH_ota-update)/scripts/$(FLASHMAP_PYTHON_SCRIPT) -p $(FLASHMAP_PLATFORM) -i $(OTA_FLASH_MAP) > flashmap.mk)
        flash_map_status=$(shell if [ -s "flashmap.mk" ]; then echo "success"; fi )
        ifeq ($(flash_map_status),)
            $(info "")
            $(error Failed to create flashmap.mk !)
            $(info "")
        else
            $(info include flashmap.mk)
            include ./flashmap.mk
        endif # flash_map_status
    endif # OTA_FLASH_MAP
    endif # FLASHMAP_PYTHON_SCRIPT
    endif # NOT getlibs
    endif # NOT get_app_info
    endif # NOT printlibs
    
endif # OTA_SUPPORT
