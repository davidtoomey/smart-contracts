pragma solidity ^0.4.18;

// Ownable + WillFactory + Will in one file
// this compiles + deploys, keeps track of Wills

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// WillFactory is Ownable is incorrect
// the WillFactory creator is the owner of
// each individual Will when calling createWill
contract WillFactory is Ownable {
  address[] public deployedWills;

  function createWill(address recipient1) public {
      address newWill = new Will(recipient1);
      deployedWills.push(newWill);

  }

  function getDeployedWills() public view returns (address[]) {
      return deployedWills;
  }
}

contract Will {

    mapping (address => bool) heirs;

    address public creatorOfWill;
    address public recipient;
    uint64 public creationTime;
    uint64 public timeStamp;
    uint64 public coolDownEndTime;
    uint public secretHashString;
    uint public coolDownIndex;
    uint public coolDownTimeLeft;
    // uint ownerCut;

    function Will(address recipient1) public payable {
        creatorOfWill = msg.sender;
        heirs[recipient1] = true;
        recipient = recipient1;
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

    function deposit() public onlyOwner payable {
        require(msg.value > 0);
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

    function getSummary() public view returns (address, uint, address) {
      return (
          recipient,
          this.balance,
          owner
      );
    }

}
