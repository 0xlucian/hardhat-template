//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IBingo {
    struct Player {
        uint8[25] card;
        uint8 gameId;
        uint256 gameStartBlock;
    }
    enum Stage {
        BETTING,
        DRAWING,
        FINISHED
    }
    struct Game {
        uint256 startBlock;
        uint256 totalBets;
        Stage stage;
        uint8 drawCount;
        bool[255] draw;
    }

    enum CombinationType {
        HORIZONTAL,
        VERTICAL,
        DIAGONAL
    }

    /// @notice Creates a new Bingo game in BETTING stage
    /// @return gameId of the newly created game
    function createNewGame() external returns (uint8 gameId);

    /// @notice Enters a game and draws a random card of numbers for the player
    /// @dev Game should be only in BETTING stage
    /// @return card of the player entered in the game
    function bet(uint8 gameId) external returns (uint8[25] memory card);

    /// @notice Draws a random number for a specific game
    /// @dev Maximum of 30 numbers can be drawn for a game.
    ///      This function enforces turnDuration betwen draws.
    function draw(uint8 gameId) external;

    /// @notice Claims a bingo for user. Bingo winner wins the whole pot of bets for the game.
    /// @dev After the game is finished it gets deleted from the games mapping
    /// @param gameId id of game to claim Bingo
    /// @param type_ the type of bingo you have (0-HORIZONTAL,1-VERTICAL,2-DIAGONAL)
    /// @return isBingo indicating if user has a bingo or not
    function claimBingo(uint8 gameId, uint8 type_) external returns (bool);

    event NewGameCreated(uint8 indexed gameId);
    event PlayerJoinedGame(uint8 indexed gameId, address indexed player);
    event Draw(uint8 indexed gameId, uint256 indexed drawnNumber);
    event BingoClaimed(
        uint8 indexed gameId,
        address indexed winner,
        uint256 prize
    );

    error NextDrawTooSoon(uint256 currentBlock, uint256 nextDrawBlock);
    error TransferFailed(uint8 gameId, address sender, address receiver);
    error WrongGameStage(uint8 expected, uint8 current);
    error AlreadyInGame(uint8 gameId, address player);
    error NotInGame(uint8 gameId, address player);
}
