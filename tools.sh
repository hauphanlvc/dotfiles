#!/bin/bash 
go install golang.org/x/tools/gopls@latest
gopls version
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
golangci-lint --version
# TypeScript Language Server
npm install -g typescript typescript-language-server

# ESLint Language Server
npm install -g vscode-langservers-extracted

# Tailwind CSS Language Server (if using Tailwind)
npm install -g @tailwindcss/language-server

npm install -D prettier eslint-config-prettier
