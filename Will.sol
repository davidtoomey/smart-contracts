pragma solidity ^0.4.18;

//work in progress

import './Ownable.sol';

contract Will is Ownable {

    mapping (address => bool) heirs;

    address public creatorOfWill;
    uint64 public creationTime;
    uint64 public timeStamp;
    uint64 public coolDownEndTime;
    uint public secretHashString;
    uint public coolDownIndex;
    uint public coolDownTimeLeft;
    // uint ownerCut;

    function Will(address recipient1) public payable {
        require(msg.value > 0);
        heirs[recipient1] = true;
        // ownerCut = msg.value * 3/100;
        startClock();
    }

    modifier onlyFamily() {
        require(msg.sender == owner || heirs[msg.sender]);
        _;
    }

    function startClock() internal onlyOwner {
        // owner.transfer(ownerCut);
        creationTime = uint64(now);
        uint64 coolDown = 30 seconds;
        // using short cooldowns for testing purposes
        coolDownEndTime = uint64(creationTime + coolDown);
    }

    function setSecretHash(string secretString) public onlyOwner {
        require(secretHashString == 0);
        secretHashString = uint(keccak256(keccak256(keccak256(secretString))));
    }

    function checkSecretHash(string hashString) public onlyOwner returns (bool) {
        checkTimeLeft();
        require(coolDownTimeLeft < 10 seconds);
        uint reHash = uint(keccak256(keccak256(keccak256(hashString))));
        require(reHash == secretHashString);
        _triggerCooldown();
        coolDownIndex++;
        return true;
    }

    function _triggerCooldown() internal {
        uint64 addTime = uint64(now + 60 seconds);
        coolDownEndTime = addTime;
        timeStamp = uint64(now);
    }

    function checkTimeLeft() public onlyFamily returns (uint) {
        uint updatedTimeLeft = uint(coolDownEndTime - now);
        coolDownTimeLeft = updatedTimeLeft;
        return coolDownTimeLeft;
    }

    function getCurrentTime() public view returns (uint64) {
        uint64 currentTime = uint64(now);
        return currentTime;
    }

    function timeSinceLastVisit() public view onlyFamily returns (uint64) {
        uint64 lastVisited = uint64(now) - timeStamp;
        return lastVisited;
    }

}
