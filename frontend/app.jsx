import React, { useState, useEffect } from 'react';
import { canisterId, createActor } from "declarations/backend";

const App = () => {
  const [board, setBoard] = useState(Array(9).fill(""));
  const [gameStatus, setGameStatus] = useState("waiting");
  const [gameResult, setGameResult] = useState("");
  const [playerSymbol, setPlayerSymbol] = useState("");
  const [isConnected, setIsConnected] = useState(false);
  const [actor, setActor] = useState(null);

  // Initialize actor without identity (anonymous user)
  useEffect(() => {
    const actorInstance = createActor(canisterId);
    setActor(actorInstance);
    setIsConnected(true); // langsung connected karena tanpa login
  }, []);

  const startGame = async (symbol) => {
    if (!actor) return;
    await actor.startGame(symbol);
    setPlayerSymbol(symbol);
    updateGameState();
  };

  const makeMove = async (index) => {
    if (!actor || gameStatus !== "player-turn") return;
    
    const result = await actor.makeMove(index);
    console.log(result);
    updateGameState();
  };

  const updateGameState = async () => {
    if (!actor) return;
    
    const [currentBoard, status, result] = await Promise.all([
      actor.getBoard(),
      actor.getGameStatus(),
      actor.getGameResult(),
    ]);
    
    setBoard(currentBoard);
    setGameStatus(status);
    setGameResult(result);
  };

  useEffect(() => {
    if (gameStatus === "bot-turn") {
      // The bot move is handled on the backend
      const timer = setTimeout(() => updateGameState(), 500);
      return () => clearTimeout(timer);
    }
  }, [gameStatus]);

  const renderCell = (index) => {
    const cellValue = board[index];
    let cellContent = "";
    let cellClass = "cell";

    if (cellValue === "X") {
      cellContent = (
        <svg viewBox="0 0 100 100" className="x-symbol">
          <line x1="10" y1="10" x2="90" y2="90" />
          <line x1="90" y1="10" x2="10" y2="90" />
        </svg>
      );
      cellClass += " x-cell";
    } else if (cellValue === "O") {
      cellContent = (
        <svg viewBox="0 0 100 100" className="o-symbol">
          <circle cx="50" cy="50" r="40" />
        </svg>
      );
      cellClass += " o-cell";
    }

    return (
      <div 
        key={index}
        className={cellClass}
        onClick={() => makeMove(index)}
      >
        {cellContent}
      </div>
    );
  };

  return (
    <div className="app">
      <header className="header">
        <h1 className="title">Tic Tac Toe on ICP</h1>
      </header>

      <main className="game-container">
        {!isConnected ? (
          <div className="connect-prompt">
            <p>Connecting...</p>
          </div>
        ) : gameStatus === "waiting" ? (
          <div className="symbol-selection">
            <h2>Choose your symbol</h2>
            <div className="symbol-options">
              <button 
                onClick={() => startGame("X")} 
                className="symbol-button x-option"
              >
                <span className="symbol-display">X</span>
                <span>Play as X (First)</span>
              </button>
              <button 
                onClick={() => startGame("O")} 
                className="symbol-button o-option"
              >
                <span className="symbol-display">O</span>
                <span>Play as O (Second)</span>
              </button>
            </div>
          </div>
        ) : (
          <>
            <div className="game-board">
              {Array(9).fill().map((_, index) => renderCell(index))}
            </div>
            <div className="game-info">
              <p className="status-message">
                {gameStatus === "player-turn" ? "Your turn!" : 
                 gameStatus === "bot-turn" ? "Bot thinking..." : ""}
              </p>
              {gameResult && (
                <div className={`result-modal ${gameResult ? "show" : ""}`}>
                  <div className="result-content">
                    <h2>{gameResult}</h2>
                    <button 
                      onClick={() => setGameStatus("waiting")}
                      className="play-again-button"
                    >
                      Play Again
                    </button>
                  </div>
                </div>
              )}
            </div>
          </>
        )}
      </main>

      <footer className="footer">
        <p>Built on Internet Computer Protocol</p>
      </footer>
    </div>
  );
};

export default App;
