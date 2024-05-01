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
installer="$(ls -1v pvcam_?*.?*.?*.?*.run | tail -n1)"
if [ ! -r "${installer}" ]; then
    echo "PVCAM installer not found in working directory."
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

function add_user_to_group() {
    local usr="${1}"
    local grp="${2}"
    echo
    echo "About to add user '${usr}' to group '${grp}'."
    while true; do
        read -n 1 -p "Do you want to continue? [Y/n]: " answer ; echo
        case "${answer}" in
            Y|y) echo ;& # Fall-through
            "")
                sudo usermod -a -G "${grp}" "${usr}"
                local err=$?
                if [ ${err} -eq 0 ]; then
                    echo "Added user '${usr}' to group '${grp}'."
                else
                    echo "Failed to add user '${usr}' to group '${grp}'."
                fi
                return ${err};;
            [Nn]) echo; return 1;;
            *) echo "Please answer either Y (yes) or N (no).";;
        esac
    done
}

## Changed to 0 whenever user skips some step
fully_installed=1

## Install packages needed before PVCAM
dkms_pkg="dkms"
if package_exists "${dkms_pkg}"; then
    if ! package_installed "${dkms_pkg}"; then
        echo "The '${dkms_pkg}' package and its dependencies automates building of PCIe driver."
        echo "It must be installed before PVCAM."
        install_packages "${dkms_pkg}" || fully_installed=0
        echo
    fi
fi

## Run the installer
bash "${installer}" || exit 1
echo

## Install all PVCAM dependencies
pkgs=(
    'libusb-1.0-0'
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
    echo "PVCAM is missing some dependencies to be fully functional."
    install_packages "${missing_pkgs[@]}" || fully_installed=0
    echo
fi

## Ensure the user is member of group 'users'
grp="users"
if ! id -Gn "${USER}" | grep -qe "^${grp} \| ${grp} \| ${grp}$"; then
    echo "PVCAM requires each user to be a member of '${grp}' group in order to access cameras without elevated permissions."
    add_user_to_group "${USER}" "${grp}" || fully_installed=0
    echo
fi

if ! dpkg-query -W -f='${Version}' "libusb-1.0-0" | grep -qe "^2:1.0.2[1-9]-.*$"; then
    echo "PVCAM requires libusb-1.0-0 version 1.0.21 or newer in order to support USB cameras."
    echo "On Ubuntu 16.04, manual installation is needed, see notes in pvcam_required_packages-Ubuntu.txt."
    fully_installed=0
    echo
fi

if [ ${fully_installed} -eq 1 ]; then
    echo "Installation fully completed."
else
    echo "Installation completed, but some steps were skipped."
fi
echo "Don't forget to reboot or re-login!"
