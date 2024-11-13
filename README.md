# ni-completion

[![GitHub license](https://img.shields.io/github/license/snowsman/ni-completion)](https://github.com/snowsman/ni-completion/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/snowsman/ni-completion)](https://github.com/snowsman/ni-completion/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/snowsman/ni-completion)](https://github.com/snowsman/ni-completion/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

🚀 Shell completion for [@antfu/ni](https://github.com/antfu-collective/ni) - making your package management commands smarter!

## ✨ Features

- 📦 Complete `ni` commands and options with intelligent context awareness
- 🔍 Dynamic package name completion from npm registry
- 📝 Automatic script completion from local package.json
- 🎯 Smart completion for scoped packages
- 🔧 Cross-platform support for Bash and Zsh

## 🚀 Installation

### Prerequisites

- [@antfu/ni](https://github.com/antfu-collective/ni) installed
- Node.js installed
- Bash or Zsh shell

### Bash

```bash
curl -o ~/.ni.bash https://raw.githubusercontent.com/snowsman/ni-completion/main/.ni.bash
echo 'source ~/.ni.bash' >> ~/.bashrc
source ~/.bashrc
```

### Zsh

```bash
mkdir -p ~/.zsh/completion
curl -o ~/.zsh/completion/_ni https://raw.githubusercontent.com/snowsman/ni-completion/main/.ni.zsh
echo 'fpath=(~/.zsh/completion $fpath)' >> ~/.zshrc
echo 'autoload -Uz compinit && compinit' >> ~/.zshrc
source ~/.zshrc
```

## 💡 Usage

| Command         | Description                                                      |
| --------------- | ---------------------------------------------------------------- |
| `ni react[TAB]` | Complete package names starting with 'react'                     |
| `ni -[TAB]`     | Show flags (-v, --version, -h, --help, -C, -g, --frozen, -i, -D) |
| `ni -C [TAB]`   | Complete directory paths                                         |
| `nr [TAB]`      | Complete available scripts from package.json                     |
| `nlx [TAB]`     | Complete executable packages                                     |
| `nun [TAB]`     | Complete installed packages from package.json                    |

For more information about `ni` commands, check README of [@antfu/ni](https://github.com/antfu-collective/ni).

## 🧪 Testing

Run the test suite:

```bash
# Bash
./test-bash.sh
# Zsh
./test-zsh.sh
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-new-feature`
3. Write tests for your changes
4. Make your changes
5. Run the tests: `./test-*.sh`
6. Commit your changes: `git commit -am 'Add some feature'`
7. Push to the branch: `git push origin feature/my-new-feature`
8. Submit a pull request

## 📄 License

[MIT License](LICENSE) © [snowsman](https://github.com/snowsman)
