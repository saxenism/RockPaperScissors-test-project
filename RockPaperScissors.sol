// SPDX-License-Identifier: GPL-3.0

pragma solidity ^ 0.8.0;

contract RockPaperScissors {
    // This event will be emitted after every game of RPS (Rock Paper Scissors)
    // Address is indexed for faster search results in logs
    event declareWinner(address indexed winner, uint winningAmount);
    
    // Let people know which two players are engaged in a match right now
    event currentPlayers(address playerOne, address playerTwo);
    
    // To let the player know in the UI that money was added.
    // Address is indexed so we can quickly find all transactions of a particular address
    event moneyAdded (address indexed player, uint money);
    
    //The contract deployer will be the contract owner initially. Hope to make this escrow
    // and when this is escrow, there will be no singular point of trust. Contract would be trustless
    address public owner;
    
    // The contract should also enable players to be able to bid their previous winnings.
    // Therefore, this mapping will keep a record of players and their winnings
    mapping(address => uint) public playerMoneyOnChain;
    
    // For the current round of Rock Paper Scissors, what is the bid of a particular address.
    mapping(address => uint) public currentBid;
    
    constructor() {
        owner = msg.sender;
    }
    
    enum RPSMoves {rock, paper, scissors, idle} 
    
    struct Player {
        address playerAddress;
        uint biddingAmount;
        bool isPlaying;
        RPSMoves playerMove;
    }
    
    struct PlayerPublicInfo {
        address playerAddress;
        uint biddingAmout;
    }
    
    // An array to keep track of all players using our dApp.
    Player[] private players;
    
    //The function that will be used by players to input money into the game.
    // This is the money that they will use to place bids.
    function depositMoneyInTheGameContract() external payable {
        playerMoneyOnChain[msg.sender] += msg.value;
        
        // An event to notify the user on the UI of the dApp.
        emit moneyAdded(msg.sender, msg.value);
    }
    
    
    // Function for the players that do not want to challenge the existing players and want to 
    // become a player(playerOne) with a new bid amount. THey submit a biddingAmount and a move for the RPS game
    function becomePlayerOne(uint biddingAmount, uint8 newPlayerOneMove) external {
        // Make sure playerOne actually has the money, they are bidding
        require(biddingAmount <= playerMoneyOnChain[msg.sender], "Please deposit more money first");
        // Make sure the RPS move they submit is a valid move
        require(uint(RPSMoves.idle) > newPlayerOneMove, "Try again with a valid move.");
        
        //Update the overall money associated with an address on this contract
        playerMoneyOnChain[msg.sender] -= biddingAmount;
        
        //Link the bid money for the current round of Rock Paper Scissor to an address
        currentBid[msg.sender] = biddingAmount;
        
        // If this function was called by an exisiting player, update values,
        // else push a new player to the players array.
        bool isNewPlayer = true;
        for(uint i = 0; i < players.length; i++) {
            if(players[i].playerAddress == msg.sender) {
                isNewPlayer = false;
                //Updating the properties of this old player
                players[i].biddingAmount = biddingAmount;
                players[i].playerMove = RPSMoves(newPlayerOneMove);
                // No need of looping further
                break;
            }
        }
        
        // Setting the properties of the new playerOne and adding that player to the list of players 
        if(isNewPlayer) {
            players.push(Player(msg.sender, biddingAmount, false, RPSMoves(newPlayerOneMove)));    
        }
    }
    
    //This function will be used to list all the players that are waiting for a challenger,
    //along with their respective bid money
    function listAvailablePlayers() external view returns (PlayerPublicInfo [] memory){
        uint availablePlayers = 0;
        
        // Finding the number of players available, since in-memory dynamic arrays are not allowed.
        for(uint i = 0; i < players.length; i++) {
            if(players[i].isPlaying == false) {
                availablePlayers++;
            }
        }
        
        // Redundant looping, but this is cheaper(gas-wise) than declaring the array playersWaiting in storage.
        PlayerPublicInfo[] memory playersWaiting = new PlayerPublicInfo[](availablePlayers);
        uint idx = 0;
        for(uint i = 0; i < players.length; i++) {
            if(players[i].isPlaying == false) {
                address reqdAddress = players[i].playerAddress;
                playersWaiting[idx++] =  PlayerPublicInfo(reqdAddress, currentBid[reqdAddress]);
            }
        }
        // This array returns the list of all players that are available to play a match along 
        // with the bid they have set up
        return playersWaiting;
    }
    
    function findWinner(address playerOneAddr, address playerTwoAddr, uint bidAmount) private returns (address winningAddress, uint winningAmount) {
        uint playerOneIdx; 
        uint playerTwoIdx;
        for(uint i = 0; i < players.length; i++) {
            if(players[i].playerAddress == playerOneAddr) {
                playerOneIdx = i; 
            } 
            else if(players[i].playerAddress == playerTwoAddr) {
                playerTwoIdx = i;
            }
        }
        RPSMoves playerOneMove = players[playerOneIdx].playerMove;
        RPSMoves playerTwoMove = players[playerTwoIdx].playerMove;
        
        //Declaring two booleans which will help reduce redundant code and determine the Winner
        bool isPlayerOneWinner = false;
        bool isPlayerTwoWinner = false;

        
        // Match was drawn. No winner
        if(uint(playerOneMove) == uint(playerTwoMove)) {
            isPlayerOneWinner = false;
            isPlayerTwoWinner = false;
        }
        // PlayerTwo wins. Paper beats Rock
        else if(playerOneMove == RPSMoves.rock && playerTwoMove == RPSMoves.paper) {
            isPlayerTwoWinner = true;
        }
        // PlayerOne wins. Rock beats Scissors
        else if(playerOneMove == RPSMoves.rock && playerTwoMove == RPSMoves.scissors) {
            isPlayerOneWinner = true;
        }
        //PlayerOne wins. Paper beats rock
        else if(playerOneMove == RPSMoves.paper && playerTwoMove == RPSMoves.rock) {
            isPlayerOneWinner = true;
        }
        //PlayerTwo wins. Scissors beats paper
        else if(playerOneMove == RPSMoves.paper && playerTwoMove == RPSMoves.scissors) {
            isPlayerTwoWinner = true;
        }
        // PlayerTwo wins. Rock beats scissors
        else if(playerOneMove == RPSMoves.scissors && playerTwoMove == RPSMoves.rock) {
            isPlayerTwoWinner = true;
        }
        // PlayerOne wins. Scissors beats paper
        else if(playerOneMove == RPSMoves.scissors && playerTwoMove == RPSMoves.paper) {
            isPlayerOneWinner = true;
        }
        // In any other situation, no one is the winner
        else {
            isPlayerOneWinner = false;
            isPlayerTwoWinner = false;
        }
        
        //No matter the outcome of the game, we will have to do these following steps.
        // Change the isPlaying boolean of both players
        players[playerOneIdx].isPlaying = false;
        players[playerTwoIdx].isPlaying = false;
        
        // Change the moves of the player to idle. So now, they can again go to challenge someone
        // Or they can again go become playerOne and set a bid and wait for a challenger to come.
        players[playerOneIdx].playerMove = RPSMoves.idle;
        players[playerTwoIdx].playerMove = RPSMoves.idle;
        
        // Match was a draw, or something unexpected happened    
        if(!isPlayerOneWinner && !isPlayerOneWinner) {
            //Return the money to the players
            playerMoneyOnChain[playerOneAddr] += bidAmount;
            playerMoneyOnChain[playerTwoAddr] += bidAmount;
            
            // Return address(0) as the winner and the winningAmount
            winningAddress = address(0);    
            winningAmount = uint(0);
        }
        // Match was won by playerOne
        else if(isPlayerOneWinner && !isPlayerTwoWinner ) {
            // Winner gets money wagered by both the players
            uint amountWonInGame = bidAmount + bidAmount;
            
            // Transferring the money to the balance of the winner
            playerMoneyOnChain[playerOneAddr] += amountWonInGame;
            
            //Return the winning address and winningAmount
            winningAddress = playerOneAddr;
            winningAmount = amountWonInGame;
        }
        // Match was won by playerTwo
        else if(!isPlayerOneWinner && isPlayerTwoWinner) {
            // Winner gets money wagered by both the players
            uint amountWonInGame = bidAmount + bidAmount;
            
            // Transferring the money to the balance of the winner
            playerMoneyOnChain[playerTwoAddr] += amountWonInGame;            
            
            //Return the winning address and winningAmount
            winningAddress = playerTwoAddr;
            winningAmount = amountWonInGame;
        }
    }
    
    // Function to challenge an existing player waiting with their set bid. Those players available for playing can be found using the 
    // function listAvailablePlayers().
    function challengePlayer(address waitingPlayerAddr, uint8 newPlayerTwoMove) external returns (address winningAddress, uint winningAmount) {
        // First ensure that playerB has enough money to challenge playerOne or not.
        require(playerMoneyOnChain[msg.sender] >= currentBid[waitingPlayerAddr], "You cannot challenge this player with your current balance");
        
        // Add this challenger to the list of players if new or update settings of the player, if player already exists
        bool isNewPlayer = true;
        for(uint i = 0; i < players.length; i++) {
            if(players[i].playerAddress == msg.sender) {
                // Make sure this old player does not enter the players array again:
                isNewPlayer = false;
                
                // Update properties of the exisiting player.
                players[i].biddingAmount = currentBid[waitingPlayerAddr];
                players[i].playerMove = RPSMoves(newPlayerTwoMove);
                players[i].isPlaying = true;
                
                // No need of looping further.
                break;
            }
        }
        if(isNewPlayer) {
            players.push(Player(msg.sender, currentBid[waitingPlayerAddr], true, RPSMoves(newPlayerTwoMove)));    
        }
        
        // Do all the procedures to indicate two players are involved in a match and not available for other matches now
        
        // Deduct the bid money from challenger's onChain wallet 
        playerMoneyOnChain[msg.sender] -= currentBid[waitingPlayerAddr];
        // Change the value of isPlaying of the player who was challenged
        for(uint i = 0; i < players.length; i++) {
            if(players[i].playerAddress == waitingPlayerAddr) { 
                players[i].isPlaying = true;
                // No need of looping further.
                break;
            }
        }
        // Emit event for the front-end of our website to know that two players are now engaged in a game.
        emit currentPlayers(waitingPlayerAddr, msg.sender);
        
        //Call the function to return the winner of the game;
        (address winningAddressTemp, uint winningAmountTemp) = findWinner(waitingPlayerAddr, msg.sender, currentBid[waitingPlayerAddr]);
        
        //Emit an event to declare the winner on the front-end
        emit declareWinner(winningAddressTemp, winningAmountTemp);
        
        // Return the winner and winning amount
        winningAddress = winningAddressTemp;
        winningAmount = winningAmountTemp;
    }
    
    // The players can use this function to view their earnings from the game so far
    // This function can be used to determine how much money the player wants to withdraw
    function viewMyBalance() public view returns (uint earnings) {
        earnings = playerMoneyOnChain[msg.sender];
    }
    
    // Function for players to withdraw some money from the money they have won/invested in the game.
    function withdrawPartialBalance(uint amount) external {
        require(playerMoneyOnChain[msg.sender] > 0 && amount < playerMoneyOnChain[msg.sender], "Invalid amount");
        playerMoneyOnChain[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transaction Failed!!");
    }
    
    //Function for players to withdraw all their money from what they have won/invested in the game.
    function withdrawFullBalance () external {
        require(playerMoneyOnChain[msg.sender] > 0, "No balance to withdraw");
        uint moneyToReturn = playerMoneyOnChain[msg.sender];
        playerMoneyOnChain[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: moneyToReturn}("");
        require(success, "Transaction Failed");
    }
}
