# Velvet PC Cleanup Tool

A simple PowerShell script for cleaning up and optimizing Windows PCs.  
Created as an educational school project to demonstrate system administration and scripting concepts.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ⚠️ Disclaimer

This is a **student project for educational purposes**.  
While it performs safe operations, always backup your data before running any system modification scripts.  
**Use at your own risk.**

---

## 🎯 What Does It Do?

Velvet performs the following cleanup operations:

1. **Creates a System Restore Point** - Safety first!  
2. **Removes Bloatware Apps** - Uninstalls unnecessary pre-installed Windows apps  
3. **Reduces Telemetry** - Minimizes data collection and diagnostics  
4. **Disables Unnecessary Services** - Stops background services you don't need  
5. **Cleans Temporary Files** - Removes temp files and Windows Update cache  
6. **Disables Cortana Web Search** - Turns off web search in Start menu  

---

## 📋 Requirements

- Windows 10 or Windows 11  
- PowerShell 5.1 or higher  
- Administrator privileges  
- Approximately 5 minutes  

---

## 🚀 How to Use

### Method 1: Download and Run

1. Download `Velvet.ps1` from this releases (https://github.com/lilacviolets/Velvet/releases/tag/1.0)  
2. Right-click on the file and select **"Run with PowerShell"**  
3. If prompted, click **"Yes"** to allow administrator privileges  
4. Follow the on-screen instructions  

### Method 2: Run Directly from GitHub

Open PowerShell as Administrator and run:

```powershell
irm https://raw.githubusercontent.com/lilacviolets/Velvet/main/Velvet.ps1 | iex
```

### Method 3: Manual Execution

1. Download `Velvet.ps1`  
2. Open PowerShell as Administrator  
3. Navigate to the download folder  
4. Run:

```powershell
.\Velvet.ps1
```

---

## 📊 What Gets Removed?

### Apps Removed

- Microsoft Bing News  
- Microsoft Bing Weather  
- Microsoft Solitaire Collection  
- Windows Alarms & Clock  
- Windows Feedback Hub  
- Groove Music (Zune Music)  
- Movies & TV (Zune Video)  

### Apps Kept

- Microsoft Office apps  
- Microsoft Store  
- Microsoft Edge  
- Calculator, Notepad, Paint  
- Windows Camera  
- Xbox *(optional, can be modified)*  

### Services Disabled

- Diagnostic Tracking Service  
- Windows Push Notifications System Service  

---

## 🔄 How to Undo Changes

If you experience any issues after running Velvet:

1. Open **Control Panel**  
2. Go to **System** → **System Protection**  
3. Click **System Restore**  
4. Select the restore point created by Velvet (named `Velvet_Backup_[date]`)  
5. Follow the wizard to restore  

---

## 🛡️ Safety Features

- ✅ Creates system restore point before making changes  
- ✅ Requires explicit user confirmation  
- ✅ Error handling for all operations  
- ✅ Detailed progress reporting  
- ✅ Safe for school and work computers  

---

## ❓ FAQ

### Is this safe to use?

Yes, but as with any system modification tool, there's always some risk.  
That's why we create a restore point first.

### Will this break my computer?

No. The script only removes non-essential apps and adjusts privacy settings.  
Critical system components are not touched.

### Can I use this on a school/work computer?

Check with your IT department first.  
Some organizations have policies against running custom scripts.

### How much space will this free up?

Typically **500MB – 2GB**, depending on your system and temp files.

### Can I customize what gets removed?

Yes! The script is open source.  
Edit the `$bloatware` array to add or remove apps.

### Will Windows Update still work?

Yes, Windows Update functions normally after running this script.

---

## 🔧 Customization

To customize which apps are removed, edit the `$bloatware` array around **line 47**:

```powershell
$bloatware = @(
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    # Add more apps here
)
```

To find the package name of an app, run this in PowerShell:

```powershell
Get-AppxPackage | Select Name
```

---

## 📝 Technical Details

- **Language:** PowerShell  
- **Admin Rights:** Required  
- **Restore Point:** Automatically created  
- **Registry Changes:** Minimal (privacy settings only)  
- **Services Modified:** DiagTrack, dmwappushservice  
- **Reboot Required:** Yes (recommended)  

---

## 🤝 Contributing

This is a school project, but suggestions and improvements are welcome!  
Feel free to:

- Report issues  
- Suggest features  
- Submit pull requests  
- Improve documentation  

---

## 📄 License

**MIT License** – Feel free to use and modify for educational purposes.

---

## 👨‍💻 Author

Created by **[lilacviolets]** as a school project to learn about Windows system administration and PowerShell scripting.

---

## 🙏 Acknowledgments

- Inspired by various Windows debloating tools  
- Thanks to teachers and classmates for feedback  
- Community contributors  

---

## 📞 Support

If you encounter issues:

1. Check the [Issues](https://github.com/lilacviolets/Velvet/issues) page  
2. Create a new issue with details about your problem  
3. Include your Windows version and error messages  

---

**⚡ Remember:** Always backup your data before running system modification scripts!  
**Made with 💜 for learning**
