#!/bin/bash
set -x

# NTP
echo "Settinng NTP Server"
sed -i "s/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g" ./package/base-files/files/bin/config_generate
sed -i "s/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g" ./package/base-files/files/bin/config_generate
sed -i "s/2.openwrt.pool.ntp.org/ntp3.aliyun.com/g" ./package/base-files/files/bin/config_generate
sed -i "s/3.openwrt.pool.ntp.org/ntp4.aliyun.com/g" ./package/base-files/files/bin/config_generate

# Timezone
echo "Settinng Timezone"
sed -i "s/UTC/CST-8/g" ./package/base-files/files/bin/config_generate
sed -i "/CST-8/a set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate

# Modify LAN IP 172.16.0.0/16
sed -i "s/192.168./172.16./g" ./package/base-files/files/bin/config_generate
sed -i "s/255.255.255.0/255.255.0.0/g" ./package/base-files/files/bin/config_generate

# Set root password(default: password)
echo "Set root password(default: password)"
sed -i 's|root.*|root:$1$pFEtE/6h$4s9J0gQfhU9wnfjnSTH5m.:18243:0:99999:7:::|g' ./package/base-files/files/etc/shadow