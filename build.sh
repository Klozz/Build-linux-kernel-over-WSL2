#!/bin/bash
# Build kernel script
# Copyright (C) 2021 The XPerience Project
# Author: Carlos "klozz" Jesus <klozz@TheXPerienceProject.org>
# TeamMEX@XDA-Developers
#

#colors?
CLR_RST=$(tput sgr0)                            ## reset flag
CLR_RED=$CLR_RST$(tput setaf 1)                 #  red, plain
CLR_GRN=$CLR_RST$(tput setaf 2)                 #  green, plain
CLR_YELLOW=$CLR_RST$(tput setaf 3)              #  yellow, plain
CLR_BLU=$CLR_RST$(tput setaf 4)                 #  blue, plain
CLR_MAGENTA=$CLR_RST$(tput setaf 5)             #  magenta, plain
CLR_CYA=$CLR_RST$(tput setaf 6)                 #  cyan, plain
CLR_BLD=$(tput bold)                            ## bold flag
CLR_BLD_RED=$CLR_RST$CLR_BLD$(tput setaf 1)     #  red, bold
CLR_BLD_GRN=$CLR_RST$CLR_BLD$(tput setaf 2)     #  green, bold
CLR_BLD_YELLOW=$CLR_RST$CLR_BLD$(tput setaf 3)  #  yellow, bold
CLR_BLD_BLU=$CLR_RST$CLR_BLD$(tput setaf 4)     #  blue, bold
CLR_BLD_MAGENTA=$CLR_RST$CLR_BLD$(tput setaf 5) #  blue, bold
CLR_BLD_CYA=$CLR_RST$CLR_BLD$(tput setaf 6)     #  cyan, bold

# Nuke scrollback
echo -e '\0033\0143'
clear
export Device=$1

echo -e "${CLR_BLD_CYA}Setting up the environment${CLR_RST}"
echo -e "${CLR_BLD_CYA}==================================================================${CLR_RST}"

echo "$(uname -r)"
if grep -q microsoft /proc/version; then
  echo "${CLR_BLD_CYA} Building over Microsoft WSL2 ${CLR_RST}"
elif grep -q generic /proc/version; then
  echo "${CLR_BLD_CYA}Building over native Linux${CLR_RST}"
else
  echo ""
fi

echo -e "${CLR_BLD_GRN} check if the LLVM compiler is here (you can edit the file for your favorite LLVM)${CLR_RST}"
if [ -d ~/tools/yukiclang ]; then
  echo "${CLR_BLD_GRN} Yuki ユキ clang found${CLR_RST}"
else
  echo "${CLR_BLD_RED} Yuki ユキ clang not found... Fetching...${CLR_RST}"
  git clone https://github.com/Klozz/Yuki-clang --depth=1 ~/tools/yukiclang
fi

echo "${CLR_BLD_GRN} Cloning anykernel ${CLR_RST}"
git clone --depth=1 https://github.com/Klozz/AnyKernel3 ~/tools/zip/$Device -b $Device

if [ "${Device}" == "miatoll" ]; then
  if [ "$FLAG_PREMIUM_BUILD" = 'y' ]; then
    if [ "${FLAG_Q_BUILD}" = 'y' ]; then
      export modelzip="Redmi-Note-9s-Pro-AOSP-Q-PREMIUM"
    else
      export modelzip="Redmi-Note-9s-Pro-AOSP-R-PREMIUM"
    fi
  elif [[ "${FLAG_R_BUILD}" = 'y' ]]; then
    export modelzip="Redmi-Note-9s-Pro-AOSP-R"
  elif [[ "${FLAG_Q_BUILD}" = 'y' ]]; then
    export modelzip="Redmi-Note-9s-Pro-AOSP-Q"
  else
    export modelzip="Redmi-Note-9s-Pro-AOSP"
  fi
  export model="Redmi Note 9s/ PRO / PRO Max / Poco M2 Pro"
fi

#track some info...

directorio=$(readlink -f .)
ANYKERNEL=~/tools/zip/$Device
Versionk=$(cat $directorio/Makefile | grep 'VERSION = ' | sed 's/.*= //' | head -1)
Patchlevel=$(cat $directorio/Makefile | grep 'PATCHLEVEL = ' | sed 's/.*= //')
SubLevel=$(cat $directorio/Makefile | grep 'SUBLEVEL = ' | sed 's/.*= //')

export KERNEL_GZ=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
ZIP_NAME=$Versionk.$Patchlevel.$SubLevel-Yuki-Kernel-$modelzip-$ZIP_DATE.zip

echo -e "${CLR_BLD_CYA}==================================================================${CLR_RST}"
echo -e "${CLR_BLD_BLU} Building... ${CLR_RST}"
export PATH="$HOME/tools/yukiclang/bin:$PATH"
make O=out ARCH=arm64 Yuki_defconfig
make -j$(nproc --all) O=out \
ARCH=arm64 \
LD=ld.lld \
NM=llvm-nm \
AR=llvm-ar \
CC="ccache clang" \
REAL_CC="ccache clang" \
CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-linux-gnu- \
CROSS_COMPILE_ARM32=arm-linux-gnueabi-

cp $directorio/out/arch/arm64/boot/Image.gz-dtb ~/tools/zip/$Device/
if [ -f $directorio/out/arch/arm64/boot/dtbo.img ]; then
  cp $directorio/out/arch/arm64/boot/dtbo.img ~/tools/zip/$Device/
fi
cd ~/tools/zip/$Device/
zip -r $ZIP_NAME * -x "*.zip*"

#only on WSL2
if grep -q microsoft /proc/version; then
  echo "$(wslpath $(cmd.exe /C "echo %USERPROFILE%"))" >a.txt
  sed -e "s/\r//g" a.txt >b.txt
  WDesktop=$(cat b.txt)
  cp $HOME/tools/zip/$Device/$ZIP_NAME ${WDesktop}/Desktop/$ZIP_NAME
  echo "${CLR_BLD_GRN} Zip file copied to $WDesktop/Desktop ${CLR_RST}"

fi

