# 🚀 Zig Project Generator (`zigcreate`) 🔧

A ⚡ lightning-fast command-line tool for scaffolding new Zig projects with a 🏗️ standardized structure in seconds!

## ✨ Features

- 🎯 **One-command setup**: `zigcreate my_awesome_project` and go!
- 📂 **Full project structure**: All the files you need, nothing you don't
- 🛡️ **Error-proof**: Checks for common mistakes before creating anything
- 📝 **Pre-configured**: Ready-to-build Zig projects out of the box

## ⚙️ Installation
# Linux 🐧
1️⃣ First, clone the repo:
```bash
git clone https://github.com/0Daviz/zigcreate.git
cd zigcreate
```

2️⃣ Then build it:
```bash
zig build
```

3️⃣ (Optional) Install globally:
```bash
sudo cp zig-out/bin/zigcreate /usr/local/bin/
```

## 🎮 Usage

Create a new project with:
```bash
zigcreate my_awesome_project
```

You'll get:
```
my_awesome_project/
├── 📜 build.zig
├── 📁 src/
│   └── 📜 main.zig
├── 📁 tests/
└── 📜 README.md
```

Need help? Just ask!:
```bash
zigcreate -h       # ℹ️ Show help
zigcreate --help   # ❓ Same thing!
```

## 🧩 What You Get

- 🏗 `build.zig`: Pre-configured build script
- 🐇 `src/main.zig`: "Hello World" starter code
- 🧪 `tests/`: Ready for your test files
- 📖 `README.md`: Basic project docs

## 🚨 Smart Error Checking

The tool catches:
- ❌ Missing project name
- 🚫 Invalid names
- ⚠️ Existing directories
- 🔒 Permission issues

## 🌟 Why You'll Love This

- ⏱️ Saves hours of project setup
- 🧠 Follows Zig best practices
- 🔄 Easy to update and customize
- 🎨 Clean, readable output

## 📜 License

MIT Licensed - Do whatever you want with it! 🎉

## 💖 Contributing

PRs welcome! Please:
- 🧹 Keep the code clean
- 🧪 Add tests for new features
- 📝 Update documentation
- 😊 Be excellent to each other
