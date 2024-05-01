#!/bin/bash

if [ ${EUID} -eq 0 ]; then
    echo "Please do not run as root"
    exit 1
fi

if [ ! -x "$(command -v apt-get)" ]; then
    echo "This OS doesn't seem to be Debian-based"
    exit 1
fi

## Find the installer (last one with newest version if found more)
installer="$(ls -1v pvcam-sdk_?*.?*.?*.?*.run | tail -n1)"
if [ ! -r "${installer}" ]; then
    echo "PVCAM SDK installer not found in working directory."
    exit 1
fi

function package_installed() {
    local pkg="${1}"
    return $(dpkg-query -W -f '${Status}\n' "${pkg}" 2>&1 | awk '/ok installed/{print 0;exit}{print 1}')
}

function package_exists() {
    local pkg="${1}"
    ## On old Debian a sudo might be needed with apt-cache
    return $(apt-cache search ^"${pkg}"$ | wc -l | awk '/0/{print 1;exit}{print 0}')
}

function install_packages() {
    local pkgs=("$@")
    if [ ${#pkgs[@]} -gt 0 ]; then
        echo
        echo "About to install following packages:"
        for pkg in "${pkgs[@]}"; do
            echo "    ${pkg}"
        done
        while true; do
            read -n 1 -p "Do you want to continue? [Y/n]: " answer ; echo
            case "${answer}" in
                Y|y) echo ;& # Fall-through
                "")
                    sudo apt-get install "${pkgs[@]}"
                    return $?;;
                [Nn]) echo; return 1;;
                *) echo "Please answer either Y (yes) or N (no).";;
            esac
        done
    fi
}

## Run the installer
bash "${installer}" || exit 1
echo

## Changed to 0 whenever user skips some step
fully_installed=1

## Install PVCAM SDK runtime dependencies
pkgs=(
    'libtiff5'
    'libwxgtk3.0-0v5'      # For PVCamTest GTK 2 version
    'libwxgtk3.0-gtk3-0v5' # For PVCamTest GTK 3 version
)
missing_pkgs=()
for pkg in "${pkgs[@]}"; do
    if package_exists "${pkg}"; then
        if ! package_installed "${pkg}"; then
            missing_pkgs+=("${pkg}")
        fi
    fi
done
if [ ${#missing_pkgs[@]} -gt 0 ]; then
    echo "PVCAM SDK is missing some runtime dependencies to be fully functional."
    install_packages "${missing_pkgs[@]}" || fully_installed=0
    echo
fi

## Install PVCAM SDK development dependencies
pkgs=(
    'build-essential'
    'libtiff5-dev'
    ## Following two packages cannot be installed together (e.g. on Ubuntu 18.04).
    ## Let user decide when both are available and neither of them is installed.
    #'libwxgtk3.0-dev'      # For building PVCamTest GTK 2 version
    #'libwxgtk3.0-gtk3-dev' # For building PVCamTest GTK 3 version
)
missing_pkgs=()
for pkg in "${pkgs[@]}"; do
    if package_exists "${pkg}"; then
        if ! package_installed "${pkg}"; then
            missing_pkgs+=("${pkg}")
        fi
    fi
done
wx_dev_pkg_gtk2='libwxgtk3.0-dev'
wx_dev_pkg_gtk3='libwxgtk3.0-gtk3-dev'
if package_exists "${wx_dev_pkg_gtk2}"; then
    if ! package_exists "${wx_dev_pkg_gtk3}"; then
        if ! package_installed "${wx_dev_pkg_gtk2}"; then
            missing_pkgs+=("${wx_dev_pkg_gtk2}")
        fi
    else ## Both available, choose one
        if package_installed "${wx_dev_pkg_gtk2}"; then
            : ## gtk2 installed, nothing to do
        elif package_installed "${wx_dev_pkg_gtk3}"; then
            : ## gtk3 installed, nothing to do
        else
            echo "wxWidgets development package is needed to rebuild PVCamTest from sources."
            echo "There is more than one package providing wxWidgets:"
            echo "    2) ${wx_dev_pkg_gtk2} - GTK 2 development (default)"
            echo "    3) ${wx_dev_pkg_gtk3} - GTK 3 development"
            echo
            while true; do
                read -n 1 -p "What package would you like to install? [2/3]: " answer ; echo
                case "${answer}" in
                    2) echo ;& # Fall-through
                    "")
                        missing_pkgs+=("${wx_dev_pkg_gtk2}")
                        break;;
                    3) echo
                        missing_pkgs+=("${wx_dev_pkg_gtk3}")
                        break;;
                    *) echo "Please answer either 2 (gtk2) or 3 (gtk3).";;
                esac
            done
        fi
    fi
elif package_exists "${wx_dev_pkg_gtk3}"; then
    if ! package_installed "${wx_dev_pkg_gtk3}"; then
        missing_pkgs+=("${wx_dev_pkg_gtk3}")
    fi
fi
if [ ${#missing_pkgs[@]} -gt 0 ]; then
    echo "PVCAM SDK is missing some development dependencies to be fully usable."
    install_packages "${missing_pkgs[@]}" || fully_installed=0
    echo
fi

if [ ${fully_installed} -eq 1 ]; then
    echo "Installation fully completed."
else
    echo "Installation completed, but some steps were skipped."
fi
