import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Random "mo:base/Random";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Blob "mo:base/Blob";

actor TicTacToe {
  type Cell = Text;
  type Board = [Cell];
  type GameResult = {#win; #draw; #ongoing};

  // Game state
  private var board : Board = ["", "", "", "", "", "", "", "", ""];
  private var playerSymbol : Text = "X";
  private var botSymbol : Text = "O";
  private var gameStatus : Text = "waiting"; // waiting, player-turn, bot-turn, finished
  private var gameResult : Text = "";

  // Initialize a new game
  public shared ({ caller }) func startGame(symbol : Text) : async Text {
    if (not (symbol == "X" or symbol == "O")) {
      return "Invalid symbol. Choose X or O";
    };

    board := ["", "", "", "", "", "", "", "", ""];
    playerSymbol := symbol;
    botSymbol := if (symbol == "X") "O" else "X";
    gameStatus := if (symbol == "X") "player-turn" else "bot-turn";
    gameResult := "";

    if (gameStatus == "bot-turn") {
      await botMove();
    };

    return "Game started. You are: " # playerSymbol;
  };

  // Player makes a move
  public shared ({ caller }) func makeMove(index : Nat) : async Text {
    if (gameStatus != "player-turn") return "Not your turn";
    if (index >= 9) return "Invalid move";
    if (board[index] != "") return "Cell already taken";

    board := Array.tabulate<Text>(9, func(i) {
      if (i == index) playerSymbol else board[i]
    });

    switch (checkGameResult(board)) {
      case (#win) {
        gameStatus := "finished";
        gameResult := "YOU WIN!";
        return "You win!";
      };
      case (#draw) {
        gameStatus := "finished";
        gameResult := "DRAW!";
        return "It's a draw!";
      };
      case (#ongoing) {
        gameStatus := "bot-turn";
        await botMove();
        return "Move accepted";
      };
    };
  };

  // Bot makes a move
  private func botMove() : async () {
    if (gameStatus != "bot-turn") return;

    // Simple AI - first look for winning move, then blocking move, then random
    let move = switch (findWinningMove(botSymbol)) {
      case (?m) m;
      case null (switch (findWinningMove(playerSymbol)) { // Block player
        case (?m) m;
        case null (await getRandomMove());
      });
    };

    board := Array.tabulate<Text>(9, func(i) {
      if (i == move) botSymbol else board[i]
    });

    switch (checkGameResult(board)) {
      case (#win) {
        gameStatus := "finished";
        gameResult := "YOU LOSE!";
      };
      case (#draw) {
        gameStatus := "finished";
        gameResult := "DRAW!";
      };
      case (#ongoing) {
        gameStatus := "player-turn";
      };
    };
  };

  // Helper functions
  private func findWinningMove(symbol : Text) : ?Nat {
    for (i in Iter.range(0, 8)) {
      if (board[i] == "") {
        let tempBoard = Array.tabulate<Text>(9, func(j) {
          if (j == i) symbol else board[j]
        });
        switch (checkGameResult(tempBoard)) {
          case (#win) return ?i;
          case _ {};
        };
      };
    };
    null;
  };

  private func getRandomMove() : async Nat {
    let emptyCells = Array.filter<Nat>(
      Array.tabulate<Nat>(9, func(i) { i }),
      func(i) { board[i] == "" }
    );

    let len = emptyCells.size();
    if (len == 0) return 0;

    // Get random bytes and convert to Nat
    let randBlob = await Random.blob();
    let randBytes = Blob.toArray(randBlob);
    
    // Use first byte to get random index
    let firstByte = if (randBytes.size() > 0) {
      Nat8.toNat(randBytes[0])
    } else {
      0
    };
    
    let index = firstByte % len;
    return emptyCells[index];
};

  private func checkGameResult(b : Board) : GameResult {
    let lines = [
      [0,1,2],[3,4,5],[6,7,8], // rows
      [0,3,6],[1,4,7],[2,5,8], // columns
      [0,4,8],[2,4,6]          // diagonals
    ];

    for (line in lines.vals()) {
      let a = line[0]; 
      let bIndex = line[1]; 
      let c = line[2];
      if (b[a] != "" and b[a] == b[bIndex] and b[a] == b[c]) {
        return #win;
      };
    };

    if (Array.filter<Text>(b, func(cell) { cell == "" }).size() == 0) {
      return #draw;
    };

    #ongoing;
  };

  // Query functions
  public query func getBoard() : async Board { board };
  public query func getGameStatus() : async Text { gameStatus };
  public query func getGameResult() : async Text { gameResult };
  public query func getPlayerSymbol() : async Text { playerSymbol };
};