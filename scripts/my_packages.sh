#!/bin/bash

# {{ Add luci-app-diskman
(cd friendlywrt/package && {
    mkdir -p feeds/luci/luci-app-diskman
    wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile.old -O feeds/luci/luci-app-diskman/Makefile
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y
CONFIG_PACKAGE_smartmontools=y
EOL
# }}

# {{ Add luci-theme-argon
(cd friendlywrt/package && {
    [ -d feeds/luci/luci-theme-argon ] && rm -rf feeds/luci/luci-theme-argon
    git clone https://github.com/jerrykuku/luci-theme-argon.git --depth 1 -b master feeds/luci/luci-theme-argon
})
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> configs/rockchip/01-nanopi
sed -i -e 's/function init_theme/function old_init_theme/g' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
cat > /tmp/appendtext.txt <<EOL
function init_theme() {
    if uci get luci.themes.Argon >/dev/null 2>&1; then
        uci set luci.main.mediaurlbase="/luci-static/argon"
        uci commit luci
    fi
}
EOL
sed -i -e '/boardname=/r /tmp/appendtext.txt' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
# }}

# {{ Add wireguard
cat >>configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-proto-wireguard=y
CONFIG_PACKAGE_wireguard-tools=y
EOL
# }}

# {{ Add openclash
(cd friendlywrt/package && {
    [ -d feeds/luci/luci-app-openclash ] && rm -rf feeds/luci/luci-app-openclash
    git clone https://github.com/vernesong/OpenClash.git -b v0.46.079 --depth 1 OpenClash
    mv OpenClash/luci-app-openclash feeds/luci/luci-app-openclash
    rm -rf OpenClash

    sleep 1
    # Add openclash kernels
    curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
    tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
    chmod +x /tmp/clash >/dev/null 2>&1
    mkdir -p feeds/luci/luci-app-openclash/root/etc/openclash/core
    mv /tmp/clash feeds/luci/luci-app-openclash/root/etc/openclash/core/clash >/dev/null 2>&1
    rm -rf /tmp/clash.tar.gz >/dev/null 2>&1

    curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-arm64-2023.08.17-13-gdcc8d87.gz -o /tmp/clash.gz
    gzip -d /tmp/clash.gz /tmp >/dev/null 2>&1
    chmod +x /tmp/clash >/dev/null 2>&1
    mv /tmp/clash feeds/luci/luci-app-openclash/root/etc/openclash/core/clash_tun >/dev/null 2>&1

    curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
    tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
    chmod +x /tmp/clash >/dev/null 2>&1
    mv /tmp/clash feeds/luci/luci-app-openclash/root/etc/openclash/core/clash_meta >/dev/null 2>&1
    rm -rf /tmp/clash.tar.gz >/dev/null 2>&1

    curl -sL -m 30 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o /tmp/GeoIP.dat
    mv /tmp/GeoIP.dat feeds/luci/luci-app-openclash/root/etc/openclash/GeoIP.dat >/dev/null 2>&1

    curl -sL -m 30 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o /tmp/GeoSite.dat
    mv /tmp/GeoSite.dat feeds/luci/luci-app-openclash/root/etc/openclash/GeoSite.dat >/dev/null 2>&1
})
cat >>configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_ca-bundle=y
CONFIG_PACKAGE_iptables=y
CONFIG_PACKAGE_ip6tables-mod-nat=y
CONFIG_PACKAGE_kmod-inet-diag=y
CONFIG_PACKAGE_ruby=y
CONFIG_PACKAGE_ruby-yaml=y
EOL
# }}
