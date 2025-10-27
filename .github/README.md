<meta property="og:title" content="Devmode CLI - Workspace Manager"
<meta property="og:description" content="Run local editor sync betw
<meta property="og:image" content="https://raw.githubusercontent.co
<meta property="og:url" content="https://github.com/esalintang/devm


![Banner](https://raw.githubusercontent.com/ezaco-dev/devmode/main/.github/image/BannerDevmode.png)

# devmode 🛠️

---

## 🎯 About
`devmode` is a shell script that simplifies managing local coding workspaces on Android or Linux devices. With devmode, you can create a workspace by selecting specific files and folders, run the workspace using popular editors (SPCK, SPCK Node.js, Acode), and automatically sync changes between your workspace and the original directory.

---

## ⚡ Features



- 📂 Create a workspace by selecting files/folders from the current directory
- 🖥️ Choose your default editor: SPCK, SPCK Node.js, or Acode
- 🔄 Automatic file synchronization between the workspace and original directory using `rsync`
- 🗑️ Easily delete workspaces along with synced files in the editor folder
- 🚫 Automatically filter out unnecessary files/folders like `node_modules`, `.git`, and log files
- 🛡️ Protect config files and build artifacts from being synced

---

## 🚀 Installation

### Android application required
- #### Text editor (<a href="https://play.google.com/store/apps/details?id=io.spck">Spck Editor</a>, <a href="https://play.google.com/store/apps/details?id=io.spck.editor.node">Spck Editor for Nodejs</a>, <a href="https://play.google.com/store/apps/details?id=com.foxdebug.acodefree">Acode</a>)
- #### Command Line <a href="https://f-droid.org/id/packages/com.termux/">Termux</a>

### 1. Setup Termux
```bash
pkg update && pkg upgrade
pkg install git rsync jq
```

### 2. Clone Github
```bash
git clone https://github.com/ezaco-dev/devmode.git
cd devmode
mkdir config
```

### 3. Give file permission
```bash
chmod +x devmode.sh
```

### 4. Create a shortcut
```bash
export DEVMODE_ALIAS="alias devmode='~/devmode/devmode"
[ -n "$PS1" ] && eval "$DEVMODE_ALIAS"
[ -n "$ZSH_VERSION" ] && source ~/.zshrc || ([ -n "$BASH_VERSION" ] && source ~/.bashrc || [ -f ~/.profile ] && source ~/.profile)
```
---
## 🗨️ Command List
### 1. help
```bash
devmode help
```
```bash
devmode
```

### 2. Creating workspace
```bash
devmode create-new-workspace
```
```bash
devmode set
```

### 3. Remove workspaces
```bash
devmode remove-workspace
```
```bash
devmode rm
```

### 4. Run the program
```bash
devmode start-workspace
```
```bash
devmode run
```
---

## 🛠️ Usage

1. When creating a new workspace, select which files/folders to include.


2. Choose the default editor (SPCK, SPCK Node.js, or Acode).


3. Run the workspace — devmode copies files and starts automatic sync.


4. Press Ctrl+C to stop syncing.


5. Use the delete workspace command to remove workspaces you no longer need.




---

## ⚙️ Configuration

Workspaces are saved as JSON files under ~/devmode/config/.

Editor folders are configured for Android (SPCK, Acode) or Linux paths.

File/folder filters exclude large folders, symlinks, and unwanted directories like node_modules.



---

## 📄 License

MIT License

