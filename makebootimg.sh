#!/bin/sh

if [ -z ${BOOT_PATH} ]; then
    echo "Please add the PATH of the images in BOOT_PATH, now defaulting to kernel/arch/arm64/boot"
    BOOT_PATH=arch/arm64/boot
fi

if [ ! -f ./ramdisk.gz ]; then
    echo "Ramdisk not found, making one..."
fi

./makeramdisk.sh

BOOT_PATH=kernel/${BOOT_PATH}

mkbootimg  --kernel ${BOOT_PATH}/Image.gz --ramdisk ./ramdisk.gz --cmdline "console=null androidboot.console=ttyHSL0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlyprintk androidboot.selinux=permissive" --base 0x80000000 --pagesize 2048 --ramdisk_offset 0x02000000 --tags_offset 0x00000100 --dt ${BOOT_PATH}/dt.img  --output ./boot.img
