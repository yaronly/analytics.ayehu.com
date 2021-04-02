#!/bin/bash

# Require script to be run as root
function super-user-check() {
    if [ "${EUID}" -ne 0 ]; then
        echo "You need to run this script as super user."
        exit
    fi
}

# Check for root
super-user-check

# Detect Operating System
function dist-check() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        DISTRO=${ID}
        DISTRO_VERSION=${VERSION_ID}
    fi
}

# Check Operating System
dist-check

# Pre-Checks system requirements
function installing-system-requirements() {
    if { [ "${DISTRO}" == "ubuntu" ] || [ "${DISTRO}" == "debian" ] || [ "${DISTRO}" == "raspbian" ] || [ "${DISTRO}" == "pop" ] || [ "${DISTRO}" == "kali" ] || [ "${DISTRO}" == "linuxmint" ] || [ "${DISTRO}" == "fedora" ] || [ "${DISTRO}" == "centos" ] || [ "${DISTRO}" == "rhel" ] || [ "${DISTRO}" == "arch" ] || [ "${DISTRO}" == "archarm" ] || [ "${DISTRO}" == "manjaro" ] || [ "${DISTRO}" == "alpine" ] || [ "${DISTRO}" == "freebsd" ]; }; then
        if { [ ! -x "$(command -v curl)" ] || [ ! -x "$(command -v iptables)" ] || [ ! -x "$(command -v bc)" ] || [ ! -x "$(command -v jq)" ] || [ ! -x "$(command -v cron)" ] || [ ! -x "$(command -v sed)" ] || [ ! -x "$(command -v zip)" ] || [ ! -x "$(command -v unzip)" ] || [ ! -x "$(command -v grep)" ] || [ ! -x "$(command -v awk)" ] || [ ! -x "$(command -v shuf)" ] || [ ! -x "$(command -v openssl)" ] || [ ! -x "$(command -v ntpd)" ]; }; then
            if { [ "${DISTRO}" == "ubuntu" ] || [ "${DISTRO}" == "debian" ] || [ "${DISTRO}" == "raspbian" ] || [ "${DISTRO}" == "pop" ] || [ "${DISTRO}" == "kali" ] || [ "${DISTRO}" == "linuxmint" ]; }; then
                apt-get update && apt-get install iptables curl coreutils bc jq sed e2fsprogs zip unzip grep gawk iproute2 systemd openssl cron ntp -y
            elif { [ "${DISTRO}" == "fedora" ] || [ "${DISTRO}" == "centos" ] || [ "${DISTRO}" == "rhel" ]; }; then
                yum update -y && yum install iptables curl coreutils bc jq sed e2fsprogs zip unzip grep gawk systemd openssl cron ntp -y
            elif { [ "${DISTRO}" == "arch" ] || [ "${DISTRO}" == "archarm" ] || [ "${DISTRO}" == "manjaro" ]; }; then
                pacman -Syu --noconfirm --needed iptables curl bc jq sed zip unzip grep gawk iproute2 systemd coreutils openssl cron ntp
            elif [ "${DISTRO}" == "alpine" ]; then
                apk update && apk add iptables curl bc jq sed zip unzip grep gawk iproute2 systemd coreutils openssl cron ntp
            elif [ "${DISTRO}" == "freebsd" ]; then
                pkg update && pkg install curl jq zip unzip gawk openssl cron ntp
            fi
        fi
    else
        echo "Error: ${DISTRO} not supported."
        exit
    fi
}

# Run the function and check for requirements
installing-system-requirements

# Global Variables
NGINX_GLOBAL_DEFAULT_CONFIG="/etc/nginx/nginx.conf"
NGINX_SITE_DEFAULT_CONFIG="/etc/nginx/sites-available/default"
GRAFANA_CONFIG_FILE="/etc/grafana/grafana.ini"

function install-grafana-on-linux() {
    if { [ "${DISTRO}" == "ubuntu" ] || [ "${DISTRO}" == "debian" ] || [ "${DISTRO}" == "raspbian" ] || [ "${DISTRO}" == "pop" ] || [ "${DISTRO}" == "kali" ] || [ "${DISTRO}" == "linuxmint" ]; }; then
        wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
        sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
        apt-get update
        apt-get install grafana nginx snapd -y
    elif { [ "${DISTRO}" == "fedora" ] || [ "${DISTRO}" == "centos" ] || [ "${DISTRO}" == "rhel" ]; }; then
        #
    elif { [ "${DISTRO}" == "arch" ] || [ "${DISTRO}" == "archarm" ] || [ "${DISTRO}" == "manjaro" ]; }; then
        #
    elif [ "${DISTRO}" == "alpine" ]; then
        #
    elif [ "${DISTRO}" == "freebsd" ]; then
        #
    fi
    snap install core
    snap refresh core
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot
}

install-grafana-on-linux

function configure-nginx() {
    if [ -f "${NGINX_SITE_DEFAULT_CONFIG}" ]; then
        rm -f ${NGINX_SITE_DEFAULT_CONFIG}
        curl https://raw.githubusercontent.com/yaronly/analytics.ayehu.com/main/default -o ${NGINX_SITE_DEFAULT_CONFIG}
    fi
    if [ -f "${NGINX_GLOBAL_DEFAULT_CONFIG}" ]; then
        sed -i "s|# server_tokens off;|server_tokens off;|" ${NGINX_GLOBAL_DEFAULT_CONFIG}
    fi
}

configure-nginx

function configure-grafana() {
    if [ -f "${GRAFANA_CONFIG_FILE}" ]; then
        rm -f ${GRAFANA_CONFIG_FILE}
        curl https://raw.githubusercontent.com/yaronly/analytics.ayehu.com/main/grafana.ini -o ${GRAFANA_CONFIG_FILE}
    fi
}

configure-grafana

function enable-grafana-service() {
    if pgrep systemd-journal; then
        systemctl enable grafana-server
        systemctl restart grafana-server
        systemctl enable ntp
        systemctl restart ntp
        systemctl enable nginx
        systemctl restart nginx
    else
        service grafana-server enable
        service grafana-server restart
        service grafana-server enable
        service grafana-server restart
        service nginx enable
        service nginx restart
    fi
}

enable-grafana-service

function issue-ssl-cert() {
    # certbot --nginx
}
