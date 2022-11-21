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

    function createNewGame() external returns (uint8 gameId);

    function bet(uint8 gameId) external returns (uint8[25] memory board);

    function draw(uint8 gameId) external;

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
