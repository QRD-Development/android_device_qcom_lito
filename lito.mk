# Enable AVB 2.0
BOARD_AVB_ENABLE := true

# Default A/B configuration
ENABLE_AB ?= true

# Enable virtual-ab by default
ENABLE_VIRTUAL_AB ?= true

ifeq ($(ENABLE_VIRTUAL_AB), true)
    $(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
endif

# Default Dynamic Partition feature configuration
BOARD_DYNAMIC_PARTITION_ENABLE ?= true

PRODUCT_SHIPPING_API_LEVEL := 29

# Temporary bring-up config -->
ALLOW_MISSING_DEPENDENCIES := true

# For QSSI builds, we should skip building the system image. Instead we build the
# "non-system" images (that we support).

# Set SYSTEMEXT_SEPARATE_PARTITION_ENABLE if was not already set (set earlier via build.sh).
SYSTEMEXT_SEPARATE_PARTITION_ENABLE ?= false

PRODUCT_BUILD_SYSTEM_IMAGE := false
PRODUCT_BUILD_SYSTEM_OTHER_IMAGE := false
PRODUCT_BUILD_VENDOR_IMAGE := true
PRODUCT_BUILD_PRODUCT_IMAGE := false
PRODUCT_BUILD_PRODUCT_SERVICES_IMAGE := false
PRODUCT_BUILD_ODM_IMAGE := false
ifeq ($(ENABLE_AB), true)
PRODUCT_BUILD_CACHE_IMAGE := false
else
PRODUCT_BUILD_CACHE_IMAGE := true
endif
PRODUCT_BUILD_RAMDISK_IMAGE := true
PRODUCT_BUILD_USERDATA_IMAGE := true

TARGET_SKIP_OTA_PACKAGE := true
TARGET_SKIP_OTATOOLS_PACKAGE := true

BUILD_BROKEN_DUP_RULES := true

ifneq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
# Enable chain partition for system, to facilitate system-only OTA in Treble.
BOARD_AVB_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
PRODUCT_BUILD_ODM_IMAGE := false
else
PRODUCT_BUILD_ODM_IMAGE := true
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_PACKAGES += fastbootd
# Add default implementation of fastboot HAL.
PRODUCT_PACKAGES += android.hardware.fastboot@1.0-impl-mock
ifeq ($(ENABLE_AB), true)
  ifeq ($(SYSTEMEXT_SEPARATE_PARTITION_ENABLE), true)
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/fstab_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.qcom
  else
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/fstab_AB_dynamic_partition_noSysext.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.qcom
  endif
else
  ifeq ($(SYSTEMEXT_SEPARATE_PARTITION_ENABLE), true)
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/fstab_non_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.qcom
  else
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/fstab_non_AB_dynamic_partition_noSysext.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.qcom
  endif
endif
BOARD_AVB_VBMETA_SYSTEM := system
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
$(call inherit-product, build/make/target/product/gsi_keys.mk)
endif

TARGET_DISABLE_PERF_OPTIMIATIONS := false

TARGET_ENABLE_QC_AV_ENHANCEMENTS := true

# privapp-permissions whitelisting (To Fix CTS :privappPermissionsMustBeEnforced)
PRODUCT_PROPERTY_OVERRIDES += ro.control_privapp_permissions=enforce

#target specific runtime prop for qspm
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.qspm.enable=true

TARGET_DEFINES_DALVIK_HEAP := true
$(call inherit-product, device/qcom/vendor-common/common64.mk)
# Temporary bring-up config <--

# Temporary bring-up config -->
PRODUCT_SUPPORTS_VERITY := false
# Temporary bring-up config <--
###########
PRODUCT_PROPERTY_OVERRIDES  += \
     dalvik.vm.heapstartsize=8m \
     dalvik.vm.heapsize=512m \
     dalvik.vm.heapgrowthlimit=256m \
     dalvik.vm.heaptargetutilization=0.75 \
     dalvik.vm.heapminfree=512k \
     dalvik.vm.heapmaxfree=8m
# Target naming
PRODUCT_NAME := lito
PRODUCT_DEVICE := lito
PRODUCT_BRAND := qti
PRODUCT_MODEL := Lito for arm64


TARGET_USES_AOSP := false
TARGET_USES_AOSP_FOR_AUDIO := false
TARGET_USES_QCOM_BSP := false

ifeq ($(TARGET_FWK_SUPPORTS_FULL_VALUEADDS),true)
  $(warning "Compiling with full value-added framework")
else
  $(warning "Compiling without full value-added framework - enabling GENERIC_ODM_IMAGE")
  GENERIC_ODM_IMAGE := true
endif

# RRO configuration
TARGET_USES_RRO := true

###########
# Kernel configurations
TARGET_KERNEL_VERSION := 4.19
#Enable llvm support for kernel
KERNEL_LLVM_SUPPORT := true
#Enable sd-llvm support for kernel
KERNEL_SD_LLVM_SUPPORT := true

###########
# Target configurations

QCOM_BOARD_PLATFORMS += lito

TARGET_USES_QSSI := true

#Default vendor image configuration
ENABLE_VENDOR_IMAGE := true

# default is nosdcard, S/W button enabled in resource
PRODUCT_CHARACTERISTICS := nosdcard

BOARD_FRP_PARTITION_NAME := frp

# Android EGL implementation
PRODUCT_PACKAGES += libGLES_android

PRODUCT_PACKAGES += fs_config_files
PRODUCT_PACKAGES += gpio-keys.kl
PRODUCT_PACKAGES += libvolumelistener

ifeq ($(ENABLE_AB), true)
# A/B related packages
PRODUCT_PACKAGES += update_engine \
    update_engine_client \
    update_verifier \
    android.hardware.boot@1.1-impl-qti \
    android.hardware.boot@1.1-impl-qti.recovery \
    android.hardware.boot@1.1-service

PRODUCT_HOST_PACKAGES += \
    brillo_update_payload
# Boot control HAL test app
PRODUCT_PACKAGES_DEBUG += bootctl


PRODUCT_PACKAGES += \
  update_engine_sideload
endif
DEVICE_FRAMEWORK_MANIFEST_FILE := device/qcom/lito/framework_manifest.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := vendor/qcom/opensource/core-utils/vendor_framework_compatibility_matrix.xml

DEVICE_MANIFEST_FILE := device/qcom/lito/manifest.xml
DEVICE_MATRIX_FILE   := device/qcom/common/compatibility_matrix.xml

#Audio DLKM
AUDIO_DLKM := audio_apr.ko
AUDIO_DLKM += audio_q6_pdr.ko
AUDIO_DLKM += audio_q6_notifier.ko
AUDIO_DLKM += audio_adsp_loader.ko
AUDIO_DLKM += audio_q6.ko
AUDIO_DLKM += audio_usf.ko
AUDIO_DLKM += audio_pinctrl_lpi.ko
AUDIO_DLKM += audio_swr.ko
AUDIO_DLKM += audio_wcd_core.ko
AUDIO_DLKM += audio_swr_ctrl.ko
AUDIO_DLKM += audio_wsa881x.ko
AUDIO_DLKM += audio_platform.ko
AUDIO_DLKM += audio_hdmi.ko
AUDIO_DLKM += audio_stub.ko
AUDIO_DLKM += audio_wcd9xxx.ko
AUDIO_DLKM += audio_mbhc.ko
AUDIO_DLKM += audio_native.ko
AUDIO_DLKM += audio_wcd938x.ko
AUDIO_DLKM += audio_wcd938x_slave.ko
AUDIO_DLKM += audio_bolero_cdc.ko
AUDIO_DLKM += audio_wsa_macro.ko
AUDIO_DLKM += audio_va_macro.ko
AUDIO_DLKM += audio_rx_macro.ko
AUDIO_DLKM += audio_tx_macro.ko
AUDIO_DLKM += audio_machine_lito.ko
AUDIO_DLKM += audio_snd_event.ko

# Kernel modules install path
KERNEL_MODULES_INSTALL := dlkm
KERNEL_MODULES_OUT := out/target/product/$(PRODUCT_NAME)/$(KERNEL_MODULES_INSTALL)/lib/modules

# MIDI feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

#FEATURE_OPENGLES_EXTENSION_PACK support string config file
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml

# Vibrator
PRODUCT_PACKAGES += \
    android.hardware.vibrator@1.0-impl \
    android.hardware.vibrator@1.0-service \

#servicetracker HAL
PRODUCT_PACKAGES += \
    vendor.qti.hardware.servicetracker@1.1-impl \
    vendor.qti.hardware.servicetracker@1.1-service \
#
# system prop for opengles version
#
# 196608 is decimal for 0x30000 to report version 3
# 196609 is decimal for 0x30001 to report version 3.1
# 196610 is decimal for 0x30002 to report version 3.2
PRODUCT_PROPERTY_OVERRIDES  += \
    ro.opengles.version=196610

# Audio configuration file
-include $(TOPDIR)hardware/qcom/audio/configs/lito/lito.mk
-include $(TOPDIR)vendor/qcom/opensource/audio-hal/primary-hal/configs/lito/lito.mk

# MIDI feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

#Enable full treble flag
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VENDOR_MOVE_ENABLED := true
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true
BOARD_SYSTEMSDK_VERSIONS := 29
BOARD_VNDK_VERSION := current
TARGET_MOUNT_POINTS_SYMLINKS := false

PRODUCT_BOOT_JARS += telephony-ext
PRODUCT_PACKAGES += telephony-ext

PRODUCT_BOOT_JARS += tcmiface

# Vendor property to enable advanced network scanning
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.enableadvancedscan=true

PRODUCT_PROPERTY_OVERRIDES += \
ro.crypto.volume.filenames_mode = "aes-256-cts" \
ro.crypto.allow_encrypt_override = true

 # f2fs utilities
 PRODUCT_PACKAGES += \
     sg_write_buffer \
     f2fs_io \
     check_f2fs

 # Userdata checkpoint
 PRODUCT_PACKAGES += \
     checkpoint_gc

 ifeq ($(ENABLE_AB), true)
  AB_OTA_POSTINSTALL_CONFIG += \
      RUN_POSTINSTALL_vendor=true \
      POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
      FILESYSTEM_TYPE_vendor=ext4 \
      POSTINSTALL_OPTIONAL_vendor=true
 endif

ifneq ($(GENERIC_ODM_IMAGE),true)
   ODM_MANIFEST_FILES += device/qcom/lito/manifest-qva.xml
else
   ODM_MANIFEST_FILES += device/qcom/lito/manifest-generic.xml
endif

#----------------------------------------------------------------------
# wlan specific
#----------------------------------------------------------------------
include device/qcom/wlan/lito/wlan.mk

###################################################################################
# This is the End of target.mk file.
# Now, Pickup other split product.mk files:
###################################################################################
# TODO: Relocate the system product.mk files pickup into qssi lunch, once it is up.
$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/system/*.mk)
$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/vendor/*.mk)
###################################################################################
