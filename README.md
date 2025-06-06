# ❌ TacToe on ICP ⭕

TacToe on ICP is a simple web-based Tic Tac Toe game built on the Internet Computer (ICP) using Motoko for the backend and React for the frontend. This project demonstrates smart contract integration with a modern user interface.

<img src="./docs/png/image1.jpg" width="300" />

<img src="./docs/png/image2.jpg" width="300" />

## 🚀 Features

- Play Tic Tac Toe locally in your browser
- Restart the board anytime
- Automatic win, draw, and turn detection
- Clean, responsive user interface with dark theme

## 🧰 Technologies

- 💻 Frontend: React + Vite
- 🧠 Backend: Motoko (Internet Computer Actor)
- 🌐 Deployment: Internet Computer (ICP Canister)
- 🎨 Styling: Custom CSS

## 📦 Installation

### 1. Clone the repository

```
git clone https://github.com/gerokaawdasa/IC-Tactoe.git
cd ic-tactoe
```

### 2. Install dependencies

```
npm install
```

### 3. Run locally

```
dfx start --background
dfx deploy
```

## 📁 Project Structure
```
ic-tactoe/
├── backend/
│   └── main.mo           # Motoko actor logic
├── frontend/
│   ├── App.jsx           # Main React component
│   ├── main.jsx          # React entry point
│   ├── style.css         # Global styles
│   └── index.html        # HTML template
├── .devcontainer/
├── dfx.json              # DFX configuration
├── package.json
└── README.md
```

## 📄 License

MIT License © 2025

