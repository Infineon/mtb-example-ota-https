################################################################################
# \file Makefile
# \version 1.0
#
# \brief
# Top-level application make file.
#
################################################################################
# \copyright
# Copyright 2018-2024, Cypress Semiconductor Corporation (an Infineon company)
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
TARGET=CY8CPROTO-062S2-43439

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

###############################################################################
#
# User configuration
#
###############################################################################

# Set Platform type
# E.g. PLATFORM=PSOC_062_512K, PLATFORM=PSOC_062_2M,  PLATFORM=XMC7200
ifeq ($(TARGET), APP_KIT_XMC72_EVK_MUR_43439M2)
PLATFORM=XMC7200
else
ifeq ($(TARGET), APP_CY8CPROTO-062S3-4343W)
PLATFORM=PSOC_062_512K
else
PLATFORM=PSOC_062_2M
endif
endif

# Core processor
ifneq ($(PLATFORM), XMC7200)
CORE=CM4
else
CORE=CM7
endif

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
COMPONENTS=FREERTOS LWIP MBEDTLS SECURE_SOCKETS

# Like COMPONENTS, but disable optional code that was enabled by default.
ifneq ($(PLATFORM), XMC7200)
DISABLE_COMPONENTS=CM0P_SLEEP CM0P_SECURE CM0P_CRYPTO CM0P_BLESS
else
DISABLE_COMPONENTS=XMC7xDUAL_CM0P_SLEEP XMC7x_CM0P_SLEEP
endif

# By default the build system automatically looks in the Makefile's directory
# tree for source code and builds it. The SOURCES variable can be used to
# manually add source code to the build process from a location not searched
# by default, or otherwise not found by the build system.
SOURCES=

# Like SOURCES, but for include directories. Value should be paths to
# directories (without a leading -I).
INCLUDES=./configs

# Custom configuration of mbedtls library.
MBEDTLSFLAGS=MBEDTLS_USER_CONFIG_FILE='"mbedtls_user_config.h"'
DEFINES+=$(MBEDTLSFLAGS)
DEFINES+=CYBSP_WIFI_CAPABLE CY_RETARGET_IO_CONVERT_LF_TO_CRLF
DEFINES+=CY_RTOS_AWARE

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
ifeq ($(TOOLCHAIN), GCC_ARM)
LDFLAGS=-Wl,--undefined=uxTopUsedPriority
CY_TOOLCHAIN_LS_EXT=ld
else
ifeq ($(TOOLCHAIN), IAR)
LDFLAGS=--keep uxTopUsedPriority
CY_TOOLCHAIN_LS_EXT=icf
else
ifeq ($(TOOLCHAIN), ARM)
LDFLAGS=--undefined=uxTopUsedPriority
LDFLAGS+=--diag_suppress=L6314W
CY_TOOLCHAIN_LS_EXT=sct
else
LDFLAGS=
$(error Selected toolchain is not supported at this moment)
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

ifeq ($(OTA_SUPPORT),1)

# Enable HTTP Support
OTA_HTTP_SUPPORT=1

# Set OTA platform type (added to defines and used when finding the linker script)
# E.g. PSOC_062_2M, PSOC_062_512K and XMC7200
OTA_PLATFORM=$(PLATFORM)

# XIP_MODE only support for PSOC_062_512K platform
XIP_MODE=XIP

# Flashmap JSON file name
ifneq ($(PLATFORM), XMC7200)
ifeq ($(PLATFORM), PSOC_062_512K)
ifeq ($(XIP_MODE), XIP)
OTA_FLASH_MAP=flashmap/psoc62_512k_xip_swap_single.json
LD_SUFFIX=_xip
endif
else
OTA_FLASH_MAP=flashmap/psoc62_2m_ext_swap_single.json
endif
else
OTA_FLASH_MAP=flashmap/xmc7200_int_swap_single.json
endif

ifneq ($(PLATFORM), XMC7200)
# To enable QSPI support
COMPONENTS+=OTA_PSOC_062
endif

# Starting from the 4.0 version of the ota-update library, the library is now fully separated from the MCUBootloader. 
# This means that it can function independently and work with any bootloader.
# This code example only supports MCUboot at this moment.
CY_BOOTLOADER=MCUBOOT
COMPONENTS+=$(CY_BOOTLOADER)

ifneq ($(CY_BOOTLOADER), MCUBOOT)
$(error This code example only supports MCUboot based bootloader at this moment)
endif

# Set the version of the app using the following three variables.
# This version information is passed to the Python module "imgtool" or "cysecuretools" while
# signing the image in the post build step. Default values are set as follows.
# Change the version here or over-ride by setting an environment variable
# before building the application.
#
# export APP_VERSION_MAJOR=2
#
APP_VERSION_MAJOR?=1
APP_VERSION_MINOR?=0
APP_VERSION_BUILD?=0

DEFINES+=OTA_SUPPORT=1\
         APP_VERSION_MAJOR=$(APP_VERSION_MAJOR)\
         APP_VERSION_MINOR=$(APP_VERSION_MINOR)\
         APP_VERSION_BUILD=$(APP_VERSION_BUILD)

# To enable the HTTP and secure socket logs.
#OTA_HTTP_DEBUG=1
#DEFINES+=OTA_HTTP_DEBUG=1
# Disable custom config header file
OTA_HTTP_USE_CUSTOM_CONFIG=0
# Set user agent name in all request headers with the specified name
OTA_HTTP_USER_AGENT_VALUE="\"ota-http-client\""
# Configure response header maximum length with the specified value - HTTP
OTA_HTTP_MAX_HDR_SIZE=2048

DEFINES+=ENABLE_OTA_LOGS\
         ENABLE_OTA_BOOTLOADER_ABSTRACTION_LOGS

# Enable the CY_PYTHON_PATH requirement.
CY_PYTHON_REQUIREMENT=true

# Python path for ota-bootloader-abstraction middlewares.
# Set Python path
ifeq ($(CY_PYTHON_PATH),)
ifeq ($(OS),Windows_NT)
CY_PYTHON_PATH?=$(shell which python)
else
CY_PYTHON_PATH?=$(shell which python3)
endif
endif # checking for Python path

# Build folder path for ota-bootloader-abstraction middleware.
CY_BUILD_LOCATION=./build

# Linker file path for ota-bootloader-abstraction middleware.
OTA_LINKER_FILE=$(wildcard bsps/TARGET_$(TARGET)/COMPONENT_$(CORE)/TOOLCHAIN_$(TOOLCHAIN)/linker$(LD_SUFFIX).$(CY_TOOLCHAIN_LS_EXT))
LINKER_SCRIPT=$(wildcard bsps/TARGET_$(TARGET)/COMPONENT_$(CORE)/TOOLCHAIN_$(TOOLCHAIN)/linker$(LD_SUFFIX).$(CY_TOOLCHAIN_LS_EXT))

# Include the ota_update.mk and mcuboot_support.mk makefiles from the middlewares.
ifneq ($(MAKECMDGOALS),getlibs)
ifneq ($(MAKECMDGOALS),get_app_info)
ifneq ($(MAKECMDGOALS),printlibs)
    include ../mtb_shared/ota-update/*-v*/makefiles/ota_update.mk
    include ../mtb_shared/ota-bootloader-abstraction/*-v*/makefiles/mcuboot/mcuboot_support.mk
endif
endif
endif

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
