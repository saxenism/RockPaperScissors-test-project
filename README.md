# A smart contract for playing Rock Paper Scissors on Ethereum Chain 

## RockPaperScissors project overview (Problem Statment):

You will create a smart contract named `RockPaperScissors` whereby:  
Alice and Bob can play the classic game of rock, paper, scissors using ERC20 (of your choosing).    
  
- To enroll, each player needs to deposit the right token amount, possibly zero.  
- To play, each Bob and Alice need to submit their unique move.  
- The contract decides and rewards the winner with all token wagered.  

There are many ways to implement this, so we leave that up to you.  
  
## Workflow of the RockPaperScissors DApp:


* There are two types of players in the game:
  * **PlayerOne**: Players who have wagered a fixed price according to their liking (their bid) and are now waiting for someone to challenge them for a game by matching their bid money.
  * **PlayerTwo**: Players who come on to challenge players waiting with their bids set. These players have to match the bid set by PlayerOne to get in a game. Or they can simply decide to become PlayerOne and wait for a challenger (PlayerTwo) at their own bid price.

* A public mapping called `currentBid` tracks the bids made by all players (all PlayerOne). 
* A public mapping called `playerMoneyOnChain` tracks the entire balance of each player that they have in the contract. Money that they win or deposit will be added here and the money they wager or lose will also be deducted from this mapping `playerMoneyOnChain`.
* Players are free to withdraw their entire balance or partial balance using the `external` functions called `withdrawPartialBalance` and `withdrawFullBalance`. They can also view their balance anytime using the `viewMyBalance` function.
* As a new user, you will first use the function `listAvailablePlayers` and decide who you want to challenge.
* If the list returned from `listAvailablePlayers` was empty, or all the players were waiting at a bid below or above of what you want to wager, you can become a playerOne, set a bid and wait for a challenger by using the function `becomePlayerOne`.
* The match can start by the two following methods:
  * You choose a player from the `listAvailablePlayers` and call the function `challengePlayer` with the address of the playerOne you chose and your move (rock or paper or scissors)
  * You did not find anyone suitable from the `listAvailablePlayers` so you became a playerOne using `becomePlayerOne` and someone challenges you by matching your bid and providing your address in the `challengePlayer` function.
* Once the match starts, both those players would not be in the list of `listAvailablePlayers` for the time being. The winner will be decided using the private function `findWinner`. The winner gets the money wagered by both the players in the mapping `playerMoneyOnChain`. The players are free to view and/or withdraw their earnings.
* In case someone is wondering, why I did not send the money to the winner directly, it is because I followed the [pull over push pattern](https://fravoll.github.io/solidity-patterns/pull_over_push.html).
* Also, not to mention, the money of the losing player gets deducted from the mapping `playerMoneyOnChain`.
* Once the game is over, both the players are free to either:
  * Withdraw their money and leave the game.
  * Challenge another player (they might require to use the `depositMoneyInTheGameContract` function)
  * Wait for a challenger by setting their bid price again (they will use the `becomePlayerOne` function again and might require to use `depositMoneyInTheGameContract` to refuel their on-chain purse)

## Some Points to consider:

* Purposely did not use any *openzeppelin* library or contract as I wanted to keep it so that it showcases my own abilites. It's kind of like, when you learn lots of *sorting algorithms* in your Algorithms class you want to implement and use that, instead of calling the in-built *sort* function of your programming language.
* Was not sure, if the challenge was still going on, therefore did not write the tests, **yet**. Working on that now.
* The contract looks like a big clunky monolithic giant right now. Once the contract pass all the edge cases in my testing, I'll write more sub-contracts to make the contract as modular as possible.


Feel free to use this smart contract anywhere you like.
You know, this smart contract is fairly well documented. Hopefully, you won't much problem understanding the logic.

Also, remember you can always [show me your support](paypal.me/saxenism).

## Strech Goals implemented:

* Make it a utility whereby any 2 people can decide to play against each other. :heavy_check_mark
  * As long as players *agree* on a particular bid amount, anyone can play anyone.
* Reduce gas costs as much as possible. ✔️
  * Kept events to a minimum. 
  * Avoided writing to the chain much
  * Used `require` instead of `assert`.
  * Used `external` wherever I could instead of using `public` everywhere
  * Avoided complex on-chain computations. 
* Let players bet their previous winnings. ✔️
  * An on-chain wallet is maintained. All transactions take place from there. You can definitely bet your previous winnings that get added to your wallet.
* How can you entice players to play, knowing that they may have their funds stuck in the contract if they face an uncooperative player? ✔️
  * My entire contract design is trustless. There is no way a malicious player can withold funds or do any foul-play.
* Include any tests using Hardhat. ℹ️
  * On-going 🤓












































  
