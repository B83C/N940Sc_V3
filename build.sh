#!/bin/bash

#cd kernel
echo "Entering ./kernel..."

NUBIA_TARGET_PRODUCT=N940Sc_V3

#leave it to empty if you don't want to use perf defconfigs
KERNEL_PERF_DEFCONFIG=perf

export ZTEMT_DTS_NAME=msm8952-mtp-${NUBIA_TARGET_PRODUCT}

export ARCH=arm64

KERNEL_DEFCONFIG=msm8952-${KERNEL_PERF_DEFCONFIG}-${NUBIA_TARGET_PRODUCT}_defconfig

DTBTOOL=~/bootimgtool/dtbtool/dtbtool

BOOT_PATH=arch/arm64/boot

#Here define the path to your gcc toolchain
#For example:
#You have extracted the prebuilt binaries to a path and all the binaries are named like this aarch64-linux-gnu-gcc, aarch64-linux-gnu-g++, etc. 
#To give you an idea how CROSS_COMPILE is to be written, look at the following:
#export CROSS_COMPILE=/path/to/my/gcc_toolchain/bin/aarch64-linux-gnu-gcc
#Easy enough, right?
#However, if you don't have a gcc cross compiling toolchain, you may download it via apt : sudo apt install gcc-<architecture of your target device>-linux-gnu
#export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE=~/downloads/toolchain/aarch64-linux-android-4.9/bin/aarch64-linux-android-

#KERNEL_MODULES_OUT=${app_build_root}/out/target/product/${NUBIA_TARGET_PRODUCT}/system/lib/modules
#function mv-modules()
#{
#	mdpath=`find ${KERNEL_MODULES_OUT} -type f -name modules.dep`
#	if [ "$mdpath" != "" ];then
#		mpath=`dirname $mdpath`
#		echo mpath=$mpath
#		ko=`find $mpath/kernel -type f -name *.ko`
#		for i in $ko
#		do
#			mv $i ${KERNEL_MODULES_OUT}/
#		done
#	fi
#}
#
#function clean-module-folder()
#{
#	mdpath=`find ${KERNEL_MODULES_OUT} -type f -name modules.dep`
#	if [ "$mdpath" != "" ];then
#		mpath=`dirname $mdpath`
#		rm -rf $mpath
#	fi
#}

echo -e "\033[01;32mBuilding .config...\033[0m"
make ${KERNEL_DEFCONFIG}

echo -e "\033[01;32mBuilding kernel...\033[0m"
make -j`grep processor /proc/cpuinfo |wc -l` 

if [ $? -gt 0 ]
then
	echo -e "\033[01;31m         Build error!!! Please see build log above         \033[0m"
	exit $RET_VAL
fi

${DTBTOOL} -v -o ${BOOT_PATH}/dt.img -s 2048 -p scripts/dtc/ ${BOOT_PATH}/dts/

#cd ..
echo "Exiting ./kernel..."

read -p "Do you wish to build a boot.img?(Y/n): " yn
case $yn in 
    [Yy]* ) BOOT_PATH=${BOOT_PATH} ./makebootimg.sh;;
    [Nn]* ) ;;
    * ) BOOT_PATH=${BOOT_PATH} ./makebootimg.sh;;
esac

#I don't see any dire need in them
#make -C kernel O=../out/target/product/${NUBIA_TARGET_PRODUCT}/obj/KERNEL_OBJ ARCH=arm64 KCFLAGS=-mno-android modules
#make -C kernel O=../out/target/product/${NUBIA_TARGET_PRODUCT}/obj/KERNEL_OBJ INSTALL_MOD_PATH=../../system INSTALL_MOD_STRIP=1 ARCH=arm64 modules_install
#echo -e "\033[01;32mmv-modules clean-module-folder...\033[0m"
#mv-modules
#clean-module-folder


echo "=============================================="
echo          Build finished at `date`.
echo	    Image.gz can be found in ${BOOT_PATH}
echo "=============================================="

