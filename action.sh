#!/bin/bash
set -x
function cleanup(){
	if [ -f /swapfile ];then
		sudo swapoff /swapfile
		sudo rm -rf /swapfile
	fi
	sudo rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc
	command -v docker && docker rmi $(docker images -q)
	sudo apt-get -y purge \
		azure-cli \
		ghc* \
		zulu* \
		hhvm \
		llvm* \
		firefox \
		google* \
		dotnet* \
		powershell \
		openjdk* \
		mysql* \
		php*
	sudo apt autoremove --purge -y
}

function init(){
	[ -f sources.list ] && (
		sudo cp -rf sources.list /etc/apt/sources.list
		sudo rm -rf /etc/apt/sources.list.d/* /var/lib/apt/lists/*z
	)
	sudo apt-get update
	sudo apt-get install make gcc g++ libncurses5-dev unzip git file wget python3 libgnutls28-dev perl libncurses5-dev libpam0g-dev liblzma-dev libssh2-1-dev libidn2-0-dev -y
	sudo apt-get install subversion g++ zlib1g-dev build-essential git python python3 libncursesw5-dev -y
	sudo apt-get install libncurses5-dev gawk gettext unzip file libssl-dev wget -y
	sudo apt-get install libelf-dev ecj -y
	sudo apt-get install qemu-utils mkisofs -y
	sudo apt-get install libpam0g-dev libssh2-1-dev libidn2-0-dev libcap-dev liblzma-dev libjansson-dev -y
	sudo apt-get install libglib2.0-dev upx zip -y
	sudo apt-get autoremove --purge -y
	sudo apt-get clean
	sudo timedatectl set-timezone Asia/Shanghai
	git config --global user.name "GitHub Action"
	git config --global user.email "action@github.com"
}

function build(){
	if [ -d openwrt ];then
		pushd openwrt
		git pull
		popd
	else
		git clone https://github.com/openwrt/openwrt.git ./openwrt
		[ -f ./feeds.conf.default ] && cat ./feeds.conf.default >> ./openwrt/feeds.conf.default
	fi
	pushd openwrt
	./scripts/feeds update -a
	./scripts/feeds install -a
	[ -d ../patches ] && git am -3 ../patches/*.patch
	[ -f ../config ] && cp -fr ../config ./.config
	make defconfig
	make download -j$(nproc) V=s
	make -j$(nproc) V=s
	popd
}

function artifact(){
	mkdir -p ./openwrt-x86-64-squashfs-img
	cp ./openwrt/bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz ./openwrt-x86-64-squashfs-img
  cp ./openwrt/bin/targets/x86/64/config.buildinfo ./openwrt-x86-64-squashfs-img
	zip -r openwrt-x86-64-squashfs-img.zip ./openwrt-x86-64-squashfs-img

	mkdir -p ./openwrt-x86-64-ext4-img
	cp ./openwrt/bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined.img.gz ./openwrt-x86-64-ext4-img
  cp ./openwrt/bin/targets/x86/64/config.buildinfo ./openwrt-x86-64-ext4-img
	zip -r openwrt-x86-64-ext4-img.zip ./openwrt-x86-64-ext4-img

	mkdir -p ./openwrt-x86-64-squashfs-vmdk
	cp ./openwrt/bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.vmdk ./openwrt-x86-64-squashfs-vmdk
  cp ./openwrt/bin/targets/x86/64/config.buildinfo ./openwrt-x86-64-squashfs-vmdk
	zip -r openwrt-x86-64-squashfs-vmdk.zip ./openwrt-x86-64-squashfs-vmdk

	mkdir -p ./openwrt-x86-64-ext4-vmdk
	cp ./openwrt/bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined.vmdk.gz ./openwrt-x86-64-ext4-vmdk
    cp ./openwrt/bin/targets/x86/64/config.buildinfo ./openwrt-x86-64-ext4-vmdk
	zip -r openwrt-x86-64-ext4-vmdk.zip ./openwrt-x86-64-ext4-vmdk
}

function auto(){
	cleanup
	init
	build
	artifact
}

$@