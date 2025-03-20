#!/bin/bash

# {{ Add wireguard
cat >>configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-proto-wireguard=y
CONFIG_PACKAGE_wireguard-tools=y
EOL
# }}

# {{ Add openclash
(cd friendlywrt/package && {
    [ -d luci-app-openclash ] && rm -rf luci-app-openclash
    git clone https://github.com/vernesong/OpenClash.git --depth 1 -b master luci-app-openclash
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

# {{ Add openclash kernels
(cd friendlywrt/package && {
    curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
    tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
    chmod +x /tmp/clash >/dev/null 2>&1
    mkdir -p feeds/luci/applications/luci-app-openclash/root/etc/openclash/core
    mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash >/dev/null 2>&1
    rm -rf /tmp/clash.tar.gz >/dev/null 2>&1

    curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-arm64-2023.08.17-13-gdcc8d87.gz -o /tmp/clash.gz
    gzip -d /tmp/clash.gz /tmp >/dev/null 2>&1
    chmod +x /tmp/clash >/dev/null 2>&1
    mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash_tun >/dev/null 2>&1

    curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
    tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
    chmod +x /tmp/clash >/dev/null 2>&1
    mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash_meta >/dev/null 2>&1
    rm -rf /tmp/clash.tar.gz >/dev/null 2>&1

    curl -sL -m 30 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o /tmp/GeoIP.dat
    mv /tmp/GeoIP.dat feeds/luci/applications/luci-app-openclash/root/etc/openclash/GeoIP.dat >/dev/null 2>&1

    curl -sL -m 30 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o /tmp/GeoSite.dat
    mv /tmp/GeoSite.dat feeds/luci/applications/luci-app-openclash/root/etc/openclash/GeoSite.dat >/dev/null 2>&1
})
# }}
