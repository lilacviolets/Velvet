## >> For Teachers: Educational Value <<

### IB PYP Exhibition Context

**Central Idea:** Technology can be used responsibly to solve everyday problems and help others.

**Transdisciplinary Theme:** How We Organize Ourselves / How the World Works

**Key Concepts Explored:**
- **Form** - Understanding how computer systems are structured
- **Function** - How software can optimize and improve systems
- **Responsibility** - Making ethical choices about technology use
- **Causation** - How software affects computer performance

**Lines of Inquiry:**
1. How computers store and organize information
2. Ways technology can solve real problems
3. The responsibility that comes with modifying systems
4. How coding can be used to help others

### What Students Learn

This project demonstrates:

1. **Computational Thinking** - Breaking problems into smaller steps
2. **Systems Understanding** - How Windows organizes apps and services
3. **Coding Skills** - Writing code in PowerShell
4. **Problem Solving** - Identifying and fixing computer slowdowns
5. **Responsibility** - Making backups before changes
6. **Communication** - Writing clear instructions for users

### PYP Attitudes Developed

- **Appreciation** - Understanding technology's role in daily life
- **Commitment** - Following through on a complex project
- **Confidence** - Sharing work with the community
- **Creativity** - Finding innovative solutions
- **Curiosity** - Exploring how computers work
- **Independence** - Self-directed learning and research
- **Integrity** - Honest about limitations and risks
- **Respect** - For users' data and system safety

### Action Component

This project promotes action by:
- Helping others solve computer problems
- Sharing knowledge with the community
- Teaching responsible technology use
- Creating open-source tools for everyone# Velvet PC Cleanup Tool

A simple PowerShell script that cleans up and speeds up Windows computers.  
Created for IB PYP Exhibition 2025 to demonstrate technology and problem-solving skills.

![PowerShell](https://img.shields.io/badge/PowerShell-3.0%2B-blue)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-1.1-brightgreen)

---

## >> Important Notice <<

This is an **IB PYP Exhibition project** created to explore how technology can solve real-world problems.  
It's safe to use, but always save your important files first.  
**Use at your own risk.**

**IB Learner Profile Connections:** Risk-taker, Thinker, Knowledgeable, Caring

---

## >> What Does This Do? <<

Velvet cleans up your Windows computer automatically. Here's what it does:

1. **[STEP 1]** Makes a backup - Creates a restore point so you can undo changes
2. **[STEP 2]** Removes junk apps - Deletes apps you probably don't use
3. **[STEP 3]** Stops data tracking - Reduces how much info Windows collects about you
4. **[STEP 4]** Turns off unused services - Stops background programs you don't need
5. **[STEP 5]** Cleans temporary files - Deletes old files taking up space
6. **[STEP 6]** Disables Cortana & Bing - Turns off web search in the start menu

---

## >> What You Need <<

Before running Velvet, make sure you have:

- Windows 10 or Windows 11
- PowerShell (already installed on Windows)
- Administrator rights (ability to make changes to the computer)
- About 5-10 minutes of time

---

## >> How to Use Velvet <<

### EASY METHOD - Download and Click

1. Go to the [Releases page](https://github.com/lilacviolets/Velvet/releases)
2. Download the file called `Velvet.ps1`
3. Right-click the file
4. Choose "Run with PowerShell"
5. Click "Yes" when asked for permission
6. Follow what appears on screen

### ADVANCED METHOD - Copy and Paste

1. Right-click the Windows Start button
2. Choose "Windows PowerShell (Admin)" or "Terminal (Admin)"
3. Copy this command:
   ```powershell
   irm https://raw.githubusercontent.com/lilacviolets/Velvet/main/Velvet.ps1 | iex
   ```
4. Right-click in the PowerShell window to paste
5. Press Enter
6. Follow the instructions

---

## >> What Gets Removed? <<

### Apps That Get Deleted

Velvet removes these apps (don't worry, you can reinstall them from the Microsoft Store):

- Bing News, Bing Weather, Bing Sports, Bing Finance
- Microsoft Solitaire Collection
- Groove Music and Movies & TV
- Windows Alarms and Clock
- Windows Feedback Hub
- 3D Builder and Print 3D
- Xbox apps (game recording and overlays)
- Your Phone app
- And about 15 more similar apps

### Apps That Stay (Important Ones)

These apps will NOT be deleted:

- Microsoft Store
- Microsoft Edge (web browser)
- Calculator, Notepad, Paint
- Camera app
- Settings
- Windows Security (antivirus)
- Your installed games and programs

### Background Services Stopped

- Diagnostic Tracking Service (sends data to Microsoft)
- Push Notification Service (for ads)
- Retail Demo Service (for store display computers)

---

## >> How to Undo Everything <<

If something goes wrong or you change your mind:

1. Click the Windows Start button
2. Type "Create a restore point"
3. Click "System Restore"
4. Choose the backup point that says "Velvet_Backup" with a date
5. Click Next and follow the steps
6. Your computer will restart and everything will be back to normal

---

## >> Safety Information <<

### What Makes This Safe?

- [✓] Creates a backup before making any changes
- [✓] Asks for your permission before doing anything
- [✓] Shows you what it's doing step-by-step
- [✓] Only removes apps you don't need
- [✓] Doesn't touch important Windows files
- [✓] Can be completely undone with System Restore

### Questions You Might Have

**Q: Will this break my computer?**  
A: No. It only removes extra apps and changes privacy settings. Important parts of Windows are not touched.

**Q: Can I use this on my school computer?**  
A: Ask your teacher or IT person first. Schools have rules about changing computer settings.

**Q: How much space will I get back?**  
A: Usually between 500 MB and 2 GB, depending on how many temporary files you have.

**Q: Will Windows Update still work?**  
A: Yes! Windows Update works normally. We only clean old update files.

**Q: Does this turn off my antivirus?**  
A: NO! Windows Security (the antivirus) stays on and keeps protecting you.

**Q: Can I run this more than once?**  
A: Yes, it's safe to run multiple times.

**Q: What if I want those apps back?**  
A: You can download them again from the Microsoft Store for free.

---

## >> Understanding the Results <<

After Velvet finishes, it shows you a summary:

```
- Removed apps: 15
- Disabled services: 3
- Space freed: 1250 MB
- Privacy changes: 5
```

This tells you:
- How many apps were deleted
- How many background programs were stopped
- How much disk space you got back
- How many privacy settings were changed

---

## >> Customization (Advanced) <<

If you know how to edit code, you can change what gets removed.

### To Add or Remove Apps from the List

1. Open `Velvet.ps1` in Notepad
2. Find the section around line 174 that says `$bloatwareApps`
3. Add or remove app names from the list
4. Save the file

Example:
```powershell
$bloatwareApps = @(
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    # Add your own apps here
)
```

### To Find App Names

Open PowerShell and type:
```powershell
Get-AppxPackage | Select-Object Name
```

This shows all app names on your computer.

---

## >> Technical Details (For Teachers) <<

### What This Script Does Technically

**Programming Language:** PowerShell  
**Minimum Requirements:** PowerShell 3.0 (works on older computers)  
**Permissions Required:** Administrator (to make system changes)  
**Safe for Students:** Yes, with supervision

### Changes Made to the Computer

1. **Registry Modifications** (5 changes)
   - Sets telemetry to minimum level
   - Disables error reporting
   - Turns off advertising ID
   - Disables Cortana
   - Disables Bing search

2. **Services Modified** (3 services)
   - DiagTrack - Stopped and disabled
   - dmwappushservice - Stopped and disabled
   - RetailDemo - Stopped and disabled

3. **Files Cleaned**
   - User temporary files
   - System temporary files
   - Windows Update cache
   - Prefetch files

4. **Scheduled Tasks**
   - Disables data collection tasks

### Should Students Restart After?

**Recommended:** Yes, restart the computer to make sure all changes work properly.  
**Required:** No, most changes work right away.

---

## >> For Teachers: Educational Value <<

### What Students Learn

This project teaches students about:

1. **Computer Systems** - How Windows organizes apps and services
2. **Programming** - Writing code in PowerShell
3. **Problem Solving** - Identifying and fixing computer slowdowns
4. **Safety** - Making backups before changes
5. **Documentation** - Writing clear instructions

### Classroom Use

- Can be used to teach system administration basics
- Demonstrates scripting and automation
- Shows practical computer maintenance
- Teaches responsibility with technology

### Safety for School Use

- **Always ask IT permission first**
- Create restore points before running
- Test on non-critical computers first
- Supervise students during use
- Review the code before allowing use

---

## >> Getting Help <<

### If Something Goes Wrong

1. **Check the FAQ section above** - Most problems are answered there
2. **Look at the Issues page** - Visit: https://github.com/lilacviolets/Velvet/issues
3. **Create a new issue** - Tell us:
   - What version of Windows you have
   - What error message you saw
   - What you were doing when it happened

### How to Report a Problem

Go to the GitHub Issues page and include:

- Windows version (type `winver` in search to find this)
- What went wrong
- What you expected to happen
- Screenshots if possible

---

## >> About This Project <<

### Who Made This?

Created by **lilacviolets** as a school project for the 2025 exhibition.

**Why was this made?**  
To learn about:
- How Windows works
- Writing PowerShell scripts
- Making computers faster
- Helping others with technology

### Special Thanks

- My teacher for guidance
- Classmates who helped test
- The Win11Debloat project for inspiration
- Everyone who provided feedback

---

## >> License <<

**MIT License** - This means:
- You can use this for free
- You can modify it for your own use
- You can share it with others
- Just keep the original credits

Full license text: https://opensource.org/licenses/MIT

---

## >> Links <<

- **Main Page:** https://github.com/lilacviolets/Velvet
- **Download:** https://github.com/lilacviolets/Velvet/releases
- **Report Problems:** https://github.com/lilacviolets/Velvet/issues

---

## >> Final Reminders <<

### Before You Run Velvet

- [✓] Save any open documents
- [✓] Close any important programs
- [✓] Make sure you have admin rights
- [✓] Read what it does above
- [✓] Have 10 minutes available

### After You Run Velvet

- [✓] Restart your computer
- [✓] Check if everything works
- [✓] Test your apps and games
- [✓] If problems happen, use System Restore

---

**Remember: Always backup your important files!**

**Made for learning | School Project 2025 | Created by lilacviolets**

---

## >> Version History <<

- **Version 1.0** - First release with basic cleanup
- **Version 1.1** - Works on older computers (PowerShell 3.0+)
- **Version 1.2** - Better error messages and safety

---

If this helped you learn something new, give it a star on GitHub!

**[STAR THIS PROJECT]** https://github.com/lilacviolets/Velvet
