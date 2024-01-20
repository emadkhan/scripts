#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if npm is installed
if ! command_exists npm; then
  echo "Error: npm is not installed. Please install Node.js and npm."
  exit 1
fi

# Check if npx is installed
if ! command_exists npx; then
  echo "Error: npx is not installed. Please install Node.js and npm."
  exit 1
fi

# Check if jq is installed
if ! command_exists jq; then
  echo "Error: jq is not installed. Please install jq."
  exit 1
fi

# Target directory is the current working directory
TARGET_DIR="."

# Change to the target directory
cd "$TARGET_DIR" || exit 1

# Initialize a new TypeScript project
echo "Initializing TypeScript project..."
npm init -y

# Install necessary dependencies
echo "Installing dependencies..."
npm install express body-parser cors
npm install --save-dev typescript jest eslint ts-node-dev @types/express @types/cors @typescript-eslint/eslint-plugin @typescript-eslint/parser

# Create a basic tsconfig.json file
echo "Creating tsconfig.json..."
echo '{
  "compilerOptions": {
    "target": "ES6",
    "outDir": "./build/",
    "module": "commonjs",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules"]
}' > tsconfig.json

# Create a directory structure
echo "Creating src dir..."
mkdir src

# Create a basic index.ts file
echo "Creating index.ts..."
echo 'import express, { Request, Response } from "express";
import bodyParser from "body-parser";
import cors from "cors";

const app = express();
app.use(express.json());

// Enable CORS
app.use(cors());

// Parse incoming JSON requests
app.use(bodyParser.json());

const PORT = 3000;

app.get("/health", (_req: Request, res: Response) => {
  res.status(200).json({ status: "ok" });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
' > src/index.ts

echo "Creating .eslintrc..."
echo '{
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "plugins": ["@typescript-eslint"],
  "env": {
    "browser": true,
    "es6": true,
    "node": true
  },
  "rules": {
    "@typescript-eslint/semi": ["error"],
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/explicit-module-boundary-types": "off",
    "@typescript-eslint/restrict-template-expressions": "off",
    "@typescript-eslint/restrict-plus-operands": "off",
    "@typescript-eslint/no-unsafe-member-access": "off",
    "@typescript-eslint/no-unused-vars": [
      "error",
      { "argsIgnorePattern": "^_" }
    ],
    "no-case-declarations": "off"
  },
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "project": "./tsconfig.json"
  }
}
' > .eslintrc

echo "Creating .eslintignore..."
echo 'node_modules/

# Output directories
/build/

# TypeScript
*.d.ts

# Editor-specific files
.vscode/

# OS generated files
.DS_Store
Thumbs.db

# Configuration files
.eslintcache
.eslintrc.js
' > .eslintignore


# Create a .gitignore file
echo "Creating .gitignore..."
echo 'node_modules

# TypeScript
*.tsbuildinfo
*.js
*.js.map

# VSCode
.vscode/

# Logs and runtime data
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# OS generated files
.DS_Store
Thumbs.db

# Dependency directory
/jspm_packages/
/pnpm-lock.yaml
/shrinkwrap.yaml
/yarn.lock

# Environment variables file
.env
.env.local
.env.*.local

# Production build output
/build/

# TypeScript cache
/.tscache/
' > .gitignore

# Update package.json with the specified "scripts" section
echo "Updating package.json..."
cat package.json | jq '.scripts = {
  "test": "jest",
  "tsc": "tsc",
  "lint": "eslint --ext .ts",
  "dev": "ts-node-dev src/index.ts",
  "start": "node build/index.js",
  "build": "tsc"
}' > temp.json && mv temp.json package.json

echo "Project setup complete. Run 'npm start' to start the server."
