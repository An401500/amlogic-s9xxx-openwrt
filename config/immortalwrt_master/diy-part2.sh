#!/bin/sh
# N1 side-router: slim config + daeuniverse honk
sed -i 's/^CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/' .config
sed -i '/^CONFIG_VERSION_NUMBER/d' .config
echo CONFIG_VERSION_NUMBER=25.12.0 >>.config
for p in luci-app-attendedsysupgrade attendedsysupgrade-common luci-i18n-attendedsysupgrade-zh-cn luci-app-diskman luci-app-diskman_INCLUDE_btrfs_progs luci-app-diskman_INCLUDE_lsblk luci-i18n-diskman-zh-cn luci-app-frpc luci-app-frps luci-i18n-frpc-zh-cn luci-i18n-frps-zh-cn frpc frps luci-app-ttyd luci-i18n-ttyd-zh-cn ttyd luci-app-upnp luci-i18n-upnp-zh-cn miniupnpd-nftables libminiupnpc luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn vlmcsd ksmbd-server kmod-fs-ksmbd luci-theme-material wireguard-tools kmod-wireguard sing-box luci-app-passwall_INCLUDE_SmartDNS kmod-cfg80211 kmod-mac80211 hostapd-common wpad-mesh-openssl; do
sed -i '/^CONFIG_PACKAGE_'"$p"'=y$/d' .config
echo '# CONFIG_PACKAGE_'"$p"' is not set' >>.config
done
mkdir -p package/base-files/files/etc/apk/keys package/base-files/files/etc/apk/repositories.d package/base-files/files/etc/uci-defaults
curl -fsSL -o package/base-files/files/etc/apk/keys/daeuniverse.pem https://openwrt.daeuniverse.org/public-key.pem || true
echo '@daeuniverse https://openwrt.daeuniverse.org/25.12/packages/aarch64_generic/packages.adb' > package/base-files/files/etc/apk/repositories.d/daeuniverse.list
printf '%s\n' '#!/bin/sh' '[ -x /usr/bin/honk ] && exit 0' '(sleep 15; apk update >/var/log/honk-install.log 2>&1; apk add honk@daeuniverse luci-app-honk@daeuniverse >>/var/log/honk-install.log 2>&1; /etc/init.d/honk enable >>/var/log/honk-install.log 2>&1) &' 'exit 0' > package/base-files/files/etc/uci-defaults/99-install-honk
chmod 755 package/base-files/files/etc/uci-defaults/99-install-honk
rm -rf package/luci-app-amlogic
git clone -b main https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
