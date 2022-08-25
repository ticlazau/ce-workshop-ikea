#!/bin/bash

sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf -y groupinstall "Development Tools"
sudo dnf -y install kernel-devel-`uname -r` kernel-headers-`uname -r`
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/ppc64le/cuda-rhel8.repo
sudo yum -y clean expire-cache
sudo dnf -y clean expire-cache

##
wget https://rpmfind.net/linux/centos/8-stream/PowerTools/ppc64le/os/Packages/opencl-filesystem-1.0-6.el8.noarch.rpm
sudo rpm -i opencl-filesystem-1.0-6.el8.noarch.rpm

sudo dnf -y module install nvidia-driver:460-dkms
sudo cp /lib/udev/rules.d/40-redhat.rules /etc/udev/rules.d/
sudo sed -i 's/SUBSYSTEM!="memory",.GOTO="memory_hotplug_end"/SUBSYSTEM=="", GOTO="memory_hotplug_end"/' /etc/udev/rules.d/40-redhat.rules

## Check if opensource drivers have been disabled
os_driver=`cat /etc/modprobe.d/blacklist-nouveau.conf| head -n 1 |awk '{print $2}'`
if [ $os_driver -eq "nouveau" ]
then
    echo "== Opensource Driver already Blacklisted =="
else
    echo "== Blacklisting Opensource Driver =="
    echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
    echo "options nouveau modeset=0" | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf
    sudo dracut --force
fi
## Reboot Node now
echo "== Driver Installation Complete =="
echo "Rebooting System"

sudo reboot
