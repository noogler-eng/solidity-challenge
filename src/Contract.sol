// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;



contract Contract {

    struct Game{
        address player_1;
        address player_2;
        uint256 point_player_1;
        uint256 point_player_2;
        bytes32[] moves;
        bool isEnd;
    }

    // this is struct containe the moves we can play
    enum Move {
        None,
        Rock,
        Paper,
        Scissor
    }
    
    // global gameId's
    uint256 public gameId;
    mapping(uint256 => Game) idToGame;

    constructor() {
        gameId = 0;
    }

    // 0. create a game
    function createGame(address _player_1, address _player_2) public {
        require(_player_1 != address(0) && _player_2 != address(0), 'enter valid address');

        bytes32[] memory moves;
        idToGame[gameId] = Game(_player_1, _player_2, 0, 0, moves, false);
        gameId++;
    }


    // 1. commit a secret move
    function commitMove(uint256 _gameId, bytes32 _move) public{
        require(_gameId < gameId, 'Invalid game id');
        require(!idToGame[_gameId].isEnd, 'game has already ended');
        require(_move != Move.None, 'Invalid move');

        Game storage game = idToGame[_gameId];
        Move[] storage moves = game.moves;
        if (moves.length % 2 == 0) {
            require(msg.sender == game.player_1, 'Not your turn, player_1 turn');
        } else {
            require(msg.sender == game.player_2, 'Not your turn, player_2 turn');
        }
        moves.push(_move);

        // even no of moves
        // checking last two moves
        if(moves.length % 2 == 0){
            determined(_gameId);
        }
    }

    // 2. determined winner
    // comparing original move with prev player's move
    function determined(uint256 _gameId, bytes32 _prevMove, bytes32 _move) internal {
        
        Game storage game = idToGame[_gameId];
        Move[] storage moves = game.moves;

        require(keccak256(abi.encodePacked(_prevMove)) == keccak256(abi.encodePacked(_move)), 'waste move!');

        Move move1 = moves[moves.length - 2];
        Move move2 = moves[moves.length - 1];

       if ((move1 == Move.Rock && move2 == Move.Scissor) ||
            (move1 == Move.Scissor && move2 == Move.Paper) ||
            (move1 == Move.Paper && move2 == Move.Rock)) {
            game.point_player_1 += 10;
        } else if (move1 != move2) {
            game.point_player_2 += 10;
        }

        if (game.point_player_1 == 50 || game.point_player_2 == 50) {
            game.isEnd = true;
        }
    }
}
