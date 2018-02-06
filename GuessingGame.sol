pragma solidity ^0.4.17;

contract GuessingGame {
    address public manager;
    address public recipient;
    mapping(address => bool) public players;
    mapping(address => bool) public winners;
    uint public playerCount;
    uint public number;
    uint public guess;
    uint public guessCount;
    uint public minimum;
    uint public rake;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function GuessingGame(uint num, address creator, uint min) public payable {
        manager = creator;
        number = num;
        minimum = min;
    }

    function setNumber(uint256 newNumber) public restricted {
        number = newNumber;
    }

    function enter() public payable {
        require(!players[msg.sender]);
        players[msg.sender] = true;
        playerCount++;
    }

    function exit() public {
        require(players[msg.sender]);
        players[msg.sender] = false;
        playerCount--;
    }

    function guessNumber(uint256 playerGuess) public {
        require(msg.sender != manager);
        require(players[msg.sender]);
        guessCount++;
        guess = playerGuess;
        require(guess == number);
        winners[msg.sender] = true;
        sendBalance();
    }

    function sendBalance() public {
        rake = this.balance*1/100;
        manager.transfer(rake);
        recipient = msg.sender;
        recipient.transfer(this.balance);
    }

    function getSummary() public view returns (address, uint, uint){
        return (
            manager,
            playerCount,
            this.balance
            );
    }

}
