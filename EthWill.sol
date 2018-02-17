pragma solidity ^0.4.18;
// work in progress 

import './Ownable.sol';

contract EthWill is Ownable {
    
    function EthWill(address recipient1) public payable {
        require(msg.value > 0);
        heirs[recipient1] = true;
        // heirs[recipient2] = true;
        // heirs[recipient3] = true;
        startClock();
    }
    
    mapping (address => bool) heirs;
    
    uint32 public myLuckyNumber;
    uint64 public creationTime;
    uint public coolDownEndTime;
    uint public coolDownIndex;
    
    // uint32[1] public cooldowns = [
    //     uint32(120 days)
    // ];
    
    function startClock() internal onlyOwner {
        creationTime = uint64(now);
        coolDownEndTime = uint64(creationTime + 120 days);
    }
    
    function setLuckyNumber(uint32 newNum) public onlyOwner {
        myLuckyNumber = newNum;
    }
    
    function luckyNumber(uint32 luckyNum) public onlyOwner {
        require(luckyNum == myLuckyNumber);
        coolDownIndex++;
        _triggerCooldown();
    }
    
    function _triggerCooldown() internal {
        // require(coolDownEndTime < 356 days);
        uint addTime = coolDownEndTime + uint64(now + 120 days);
        coolDownEndTime = addTime;
    }

}
