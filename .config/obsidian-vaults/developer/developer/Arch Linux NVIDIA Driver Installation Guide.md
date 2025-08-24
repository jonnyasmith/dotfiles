This guide covers the installation and troubleshooting steps for the proprietary NVIDIA drivers on Arch Linux, particularly for modern laptops with hybrid graphics. The key is using the `nvidia-dkms` package to ensure compatibility with kernel updates.

## 1. Initial Installation

First, ensure your system is fully up to date. Then, install the necessary packages.

- **`nvidia-dkms`**: The driver itself. The DKMS version automatically rebuilds the module for new kernels.
    
- **`nvidia-settings`**: The graphical control panel for the driver.
    
- **`linux-headers`**: Essential for DKMS to build the driver modules.
    

```
# Ensure system is up to date
sudo pacman -Syu

# Install the required packages
sudo pacman -S nvidia-dkms nvidia-settings linux-headers
```

## 2. The Core Problem: Driver Not Loading

After installation and a reboot, you may find the proprietary driver is not active.

### Verification

Check which driver is in use with `lspci -k`. Filter for your NVIDIA device:

```
lspci -k | grep -A 2 -E "NVIDIA|3D"
```

If the output shows `Kernel driver in use: nouveau`, the system has defaulted to the open-source driver and the proprietary one is not loading.

## 3. The Fix: Forcing the NVIDIA Modules to Load

This involves three crucial steps: blacklisting the old driver, forcing the new modules into the boot image, and then regenerating that image.

### Step 3a: Blacklist the `nouveau` Driver

Create a modprobe configuration file to prevent the `nouveau` module from loading at boot.

```
# Create and edit the new configuration file
sudo nano /etc/modprobe.d/blacklist-nouveau.conf
```

Add the following single line to this file:

```
blacklist nouveau
```

Save and close the file (`Ctrl+X`, `Y`, `Enter`).

### Step 3b: Force NVIDIA Modules into the Boot Image

Edit the `mkinitcpio` configuration to explicitly include the NVIDIA modules. This ensures they are loaded early in the boot process.

```
sudo nano /etc/mkinitcpio.conf
```

Find the line that begins with `MODULES=`. It will likely be empty: `MODULES=()`. Add the NVIDIA modules to it like so:

```
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Save and close the file.

### Step 3c: Rebuild the Boot Image

Apply the changes by regenerating the initramfs for all installed kernels.

```
sudo mkinitcpio -P
```

During this process, you may see `ERROR: module not found` if the DKMS build failed. If this happens, reinstalling `nvidia-dkms` (`sudo pacman -S nvidia-dkms`) will force a rebuild. If the process completes without these specific errors, you are good to go.

## 4. Final Verification and Reboot

### Disable Secure Boot

The proprietary NVIDIA driver is not signed in a way that Secure Boot will accept. You **must** disable Secure Boot in your computer's BIOS/UEFI settings for the module to be allowed to load.

### Reboot and Verify

After rebooting, run the verification command again:

```
lspci -k | grep -A 2 -E "NVIDIA|3D"
```

The output should now confirm the correct driver is active:

```
01:00.0 3D controller: NVIDIA Corporation TU117M [GeForce GTX 1650 Ti Mobile] (rev a1)
        Subsystem: Dell Device 097d
        Kernel driver in use: nvidia
```

You can also launch the `nvidia-settings` application, which should now be fully populated with your GPU's information.

## 5. Note on Kernel Updates

Because you used `nvidia-dkms`, every time you update the kernel (`sudo pacman -Syu`), you will see a process where the old DKMS module is removed and a new one is built and installed for the new kernel. This is **normal and expected**. It is the system automatically keeping your graphics driver in sync with the kernel, preventing breakages.