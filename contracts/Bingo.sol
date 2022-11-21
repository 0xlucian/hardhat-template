pragma solidity ^0.8.9;

import "./IBingo.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Bingo Game Contract
/// @author 0xLucian
contract Bingo is IBingo {
    address immutable token;
    address immutable owner = msg.sender;
    uint256 entryFee;
    uint256 turnDuration;
    uint256 joinDuration;
    uint8 private gamesCounter = 0;
    uint8 constant CARD_MIDDLE_SPOT_IDX = 12;
    mapping(uint256 => Game) games;
    mapping(address => Player) players;

    constructor(
        address token_,
        uint256 entryFee_,
        uint256 turnDuration_,
        uint256 joinDuration_
    ) {
        token = token_;
        entryFee = entryFee_;
        turnDuration = turnDuration_;
        joinDuration = joinDuration_;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @notice Creates a new Bingo game in BETTING stage
    /// @return gameId of the newly created game
    function createNewGame() external override returns (uint8 gameId) {
        gameId = gamesCounter;
        Game memory newGame;
        newGame.startBlock = block.number + joinDuration;
        newGame.stage = Stage.BETTING;
        newGame.draw[0] = true;
        games[gameId] = newGame;
        unchecked {
            gamesCounter++;
        }
        emit NewGameCreated(gameId);
    }

    /// @notice Enters a game and draws a random card of numbers for the player
    /// @dev Game should be only in BETTING stage
    /// @return card of the player entered in the game
    function bet(uint8 gameId)
        external
        override
        returns (uint8[25] memory card)
    {
        Game memory game = games[gameId];
        Player memory player = players[msg.sender];
        if (
            game.startBlock == player.gameStartBlock && gameId == player.gameId
        ) {
            revert AlreadyInGame(gameId, msg.sender);
        } else if (game.stage != Stage.BETTING) {
            revert WrongGameStage(uint8(Stage.BETTING), uint8(game.stage));
        } else if (block.number >= game.startBlock) {
            game.stage = Stage.DRAWING;
        }
        uint256 entryFee_ = entryFee;
        bool success = IERC20(token).transferFrom(
            msg.sender,
            address(this),
            entryFee_
        );
        if (!success) {
            revert TransferFailed(gameId, msg.sender, address(this));
        }
        game.totalBets += entryFee_;
        bytes32 blockHashPrevious = blockhash(block.number - 1);
        uint256 seed = uint256(blockHashPrevious);

        uint256 i;
        while (i < 25) {
            if (i == CARD_MIDDLE_SPOT_IDX) {
                ++i;
                continue;
            }
            uint256 bigRandNum = uint256(keccak256(abi.encodePacked(seed, i)));
            uint256 cardNumber;
            unchecked {
                cardNumber = 1 + (bigRandNum % 255);
            }
            card[i] = uint8(cardNumber);
            ++i;
        }
        player.card = card;

        players[msg.sender] = player;
        emit PlayerJoinedGame(gameId, msg.sender);
    }

    /// @notice Draws a random number for a specific game
    /// @dev Maximum of 30 numbers can be drawn for a game.
    ///      This function enforces turnDuration betwen draws.
    function draw(uint8 gameId) external override {
        Game memory game = games[gameId];
        if (game.stage != Stage.DRAWING) {
            revert WrongGameStage(uint8(Stage.DRAWING), uint8(game.stage));
        } else if (
            block.number <= game.startBlock + (game.drawCount * turnDuration)
        ) {
            revert NextDrawTooSoon(
                block.number,
                game.startBlock + (game.drawCount * turnDuration)
            );
        }
        bytes32 blockHashPrevious = blockhash(block.number - 1);
        uint256 seed = uint256(blockHashPrevious);
        uint256 bigRandNum = uint256(keccak256(abi.encodePacked(seed, gameId)));
        uint256 drawnNumber = 1 + (bigRandNum % 255);
        game.draw[uint8(drawnNumber)] = true;
        if (game.drawCount == 29) {
            game.stage = Stage.FINISHED;
        } else {
            ++game.drawCount;
        }
        emit Draw(uint8(gameId), drawnNumber);
    }

    /// @notice Claims a bingo for user. Bingo winner wins the whole pot of bets for the game.
    /// @dev After the game is finished it gets deleted from the games mapping
    /// @param gameId id of game to claim Bingo
    /// @param type_ the type of bingo you have (0-HORIZONTAL,1-VERTICAL,2-DIAGONAL)
    /// @return isBingo indicating if user has a bingo or not
    function claimBingo(uint8 gameId, uint8 type_)
        external
        override
        returns (bool isBingo)
    {
        Player memory player = players[msg.sender];
        Game memory game = games[gameId];
        if (game.stage == Stage.BETTING) {
            revert WrongGameStage(uint8(Stage.DRAWING), uint8(game.stage));
        } else if (
            game.startBlock != player.gameStartBlock || gameId == player.gameId
        ) {
            revert NotInGame(gameId, msg.sender);
        }

        if (type_ == uint8(CombinationType.HORIZONTAL)) {
            uint256 rowDecoderIdx;
            for (uint256 i; i < 5; ++i) {
                rowDecoderIdx = i * 5;
                if (
                    game.draw[player.card[rowDecoderIdx]] &&
                    game.draw[player.card[rowDecoderIdx + 1]] &&
                    game.draw[player.card[rowDecoderIdx + 2]] &&
                    game.draw[player.card[rowDecoderIdx + 3]] &&
                    game.draw[player.card[rowDecoderIdx + 4]]
                ) {
                    isBingo = true;
                }
            }
        } else if (type_ == uint8(CombinationType.DIAGONAL)) {
            if (
                (game.draw[player.card[0]] &&
                    game.draw[player.card[6]] &&
                    game.draw[player.card[12]] &&
                    game.draw[player.card[18]] &&
                    game.draw[player.card[24]]) ||
                (game.draw[player.card[4]] &&
                    game.draw[player.card[8]] &&
                    game.draw[player.card[12]] &&
                    game.draw[player.card[16]] &&
                    game.draw[player.card[20]])
            ) {
                isBingo = true;
            }
        } else {
            //VERTICAL CHECK
            for (uint256 i; i < 5; ++i) {
                if (
                    game.draw[player.card[0 * 5 + i]] &&
                    game.draw[player.card[1 * 5 + i]] &&
                    game.draw[player.card[2 * 5 + i]] &&
                    game.draw[player.card[3 * 5 + i]] &&
                    game.draw[player.card[4 * 5 + i]]
                ) {
                    isBingo = true;
                }
            }
        }
        if (isBingo) {
            uint256 amountToTransfer = game.totalBets;
            delete games[gameId];
            bool success = IERC20(token).transfer(msg.sender, amountToTransfer);
            if (!success) {
                revert TransferFailed(gameId, address(this), msg.sender);
            }
            emit BingoClaimed(gameId, msg.sender, amountToTransfer);
        }
    }

    /// @notice Sets the entry fee for betting in a game
    /// @param entryFee_ new entry fee param
    function setEntryFee(uint256 entryFee_) external onlyOwner {
        entryFee = entryFee;
    }

    /// @notice Sets the join duration before the game starts
    /// @param joinDuration_ new join duration param
    function setJoinDuration(uint256 joinDuration_) external onlyOwner {
        joinDuration = joinDuration_;
    }

    /// @notice Sets the turn duration between draws
    /// @param turnDuration_ new turn duration param
    function setTurnDuration(uint256 turnDuration_) external onlyOwner {
        turnDuration = turnDuration_;
    }
}
