# Virtual Machine
## Adding a graphical interface to your existing  Debian VM.

1. Update package List First:
```bash
sudo apt-get update && sudo apt-get upgrade -y
```

2. Install XFCE4 (lightweight desktop environment recommended for VMs):
```bash
sudo apt-get install -y xfce4 xfce4-terminal
```

3. Install Display Manager (lightdm is recommended):
```bash
sudo apt-get install -y lightdm
```

4. Install Additional Tools (optional but useful):
```bash
sudo apt-get install -y firefox-esr
sudo apt-get install -y thunar
```

5. Start the Display Manager:
```bash
sudo systemctl start lightdm
```

6. Enable Display Manager on Boot:
```bash
sudo system enable lightdm
```

7. VirtualBox Settings:
Shutdown VM first:
```bash
sudo shutdown -h now
```

* In VirtualBox Manager:
	1. Select your VM
	2. Click Settings
	3. Under Display:
		- Increase Video Memory to at least 32MB
		- Enable 3D Acceleration
	4. Start VM again

Remember:

* Your WordPress configuration in wp_conf.sh and other Docker services will continue to work as before
* The GUI is just an additional layer on top of your existing setup
* You can always switch between GUI and command line using `Ctrl+Alt+F1` through `F7`