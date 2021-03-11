# Ubuntu desktop installation checklist

Executable documentation for setting up my Ubuntu desktop environment. 

## Usage

Go through the checklist and optionally install item:

```
./checklist.sh
===========
📦 Packages
===========
🤖 Install 'ansible'?
y
✅ ansible installed

🤖 Install 'curl'?
n
⏭  curl installation skipped

🤖 Install 'docker'?
y
✅ docker installed
```

Report which items from the checklist are installed:

```
./checklist.sh report
===========
📦 Packages
===========
✅ ansible
❌ curl
✅ docker
```