#!/bin/bash
# Sets some shortcuts for terminal colors to spice things up
COLOR_N="\033[0m"
COLOR_R="\033[0;31m"
COLOR_G="\033[1;32m"
COLOR_B="\033[0;34m"
COLOR_C="\033[0;36m"
COLOR_Y="\033[1;33m"
COLOR_LP="\033[1;35m"
# This is where the paths for your compiler layout go, as well as the kernel's name.
KERNEL_NAME="SwanKernel"
#DTC=/var/lib/snapd/snap/bin/dtc
CLANG_TRIPLE_COMP=$HOME/toolchains/clang_kernel4.9/bin/aarch64-linux-gnu-
GCC_AARCH64=$HOME/toolchains/gcc64/bin/aarch64-linux-android-
GCC_ARM32=$HOME/toolchains/gcc32/bin/arm-linux-androideabi-
CLANG_CC=$HOME/toolchains/clang_kernel4.9/bin/clang
SHOW_PATHS(){
	echo "Printing all compiler paths and the kernel's name:"
	echo "DTC_EXT(optional): $DTC"
	echo "CLANG_TRIPLE: $CLANG_TRIPLE_COMP"
	echo "GCC_CC_AARCH64: $GCC_AARCH64"
	echo "GCC_CC_ARM32: $GCC_ARM32"
	echo "CLANG_CC: $CLANG_CC"
	echo "KERNEL_NAME: $KERNEL_NAME"
	while true; do
		echo -e $COLOR_Y
		read -p "Are those paths and kernel name all correct (y or n)? " yn
		echo -e $COLOR_N
		case $yn in
			[Yy]* ) CHECK_CLEAN && break ;;
			[Nn]* ) echo -e $COLOR_R"Please change the paths in build.sh then try again" && break ;;
		* ) echo -e $COLOR_R"Please answer either y or n" $COLOR_N ;;
		esac
	done
}
CHECK_CLEAN(){
	if [ -f "$(pwd)/KernelOut/.config" ]; then
		while true; do
		    	echo -e $COLOR_Y
		    	echo -e "There's already a previous build config, you can opt to rebuild only the files that were changed."
		    	echo -e "If you opt not to, the build folder will be cleaned and a clean rebuild will be triggered. "
			read -p "Would you like to rebuild only the changes (y or n)? " yn
		    	echo -e $COLOR_N
		    	case $yn in
		      		[Nn]* ) CLEAN_BUILD && break ;;
		      		[Yy]* ) BUILD_KERNEL && break ;;
		      		* ) echo -e $COLOR_R"Please answer either y or n" $COLOR_N ;;
		    	esac
		done
	else
		echo -e $COLOR_C"No previous build folder found, doing a clean build..." $COLOR_N
		BUILD_KERNEL
	fi
}
CLEAN_BUILD(){
	echo -e $COLOR_LP"Cleaning build folder..."$COLOR_N
	rm -rf KernelOut
	mkdir KernelOut
	make O=KernelOut/ clean
	make O=KernelOut/ mrproper
	echo -e $COLOR_LP"Build folder was cleaned!"$COLOR_N
	BUILD_KERNEL
}
BUILD_KERNEL(){
	echo -e $COLOR_C"\n\nBeginning compilation for mido...\n\n" $COLOR_N
	make O=KernelOut/ ARCH=arm64 mido_defconfig
	if ! make -j$(nproc --all) O=KernelOut/ \
	KBUILD_BUILD_VERSION=$KERNEL_NAME \
	ARCH=arm64 DTC_EXT=$DTC \
	CLANG_TRIPLE=$CLANG_TRIPLE_COMP \
	CROSS_COMPILE=$GCC_AARCH64 \
	CROSS_COMPILE_ARM32=$GCC_ARM32 \
	CC=$CLANG_CC ; then
		echo -e $COLOR_R"\nThe kernel couldn't be compiled... check for errors above.\n"$COLOR_N
		exit 1
	fi
	echo -e $COLOR_C"\nThe kernel has been compiled successfully!\n"$COLOR_N
}
# This is how you call a function like the ones below. This one makes the script start by printing the paths
# You can remove that step bu simply changing that call for CHECK_CLEAN for example.
SHOW_PATHS
