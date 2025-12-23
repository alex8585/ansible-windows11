# Windows 11 Program Installation Playbook

This Ansible playbook automates the installation of several programs on Windows 11 and optionally creates shortcuts for them. It is designed to simplify setting up a new Windows machine with common software.

## Requirements

- **Ansible** installed on a control machine (Linux/Mac/WSL)
- **Windows 11** host with:
  - PowerShell remoting enabled
  - WinRM configured for remote management
- Internet access on the Windows host to download installer files

## Programs Installed

The playbook installs the following programs:

| Program   | Source URL |
|-----------|------------|
| 7-Zip     | https://www.7-zip.org |
| Notepad++ | https://github.com/notepad-plus-plus |
| PuTTY     | https://the.earth.li/~sgtatham/putty/ |

Each program is downloaded to `C:\Temp` and installed silently using the specified installer arguments.

## Variables

- `programs`: A list of programs with their download URL, destination file, installation path, and installation arguments. You can modify or add new programs here.

Example:

```yaml
programs:
  - name: "7-Zip"
    url: "https://www.7-zip.org/a/7z2301-x64.exe"
    dest_file: "C:\\Temp\\7z2301-x64.exe"
    install_path: "C:\\Program Files\\7-Zip\\7zFM.exe"
    args: "/S"
```

## Usage

1. Ensure your Windows host is reachable and configured for WinRM.
2. Clone this repository to your control machine.
3. Run the playbook:

```bash
ansible-playbook -i hosts.ini install_windows_programs.yml
```

Replace `hosts.ini` with your inventory file and `install_windows_programs.yml` with the main playbook file name.

## Tasks Performed

- Create `C:\Temp` folder if it does not exist.
- Download installers for each program listed in the `programs` variable.
- Install each program silently.
- Optionally, create shortcuts for the installed programs.

## License

This project is licensed under the MIT License.
