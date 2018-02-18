pragma solidity ^0.4.18;

// work in progress

import './Will.sol';

contract WillFactory {

    address[] public deployedWills;
    address public ceoAddress;

    function WillFactory() public {
        ceoAddress = msg.sender;
    }

    function createWill(address recipient) public payable {
        // uint sum = msg.value;
        // uint _cut = sum * 3/100;
        // WillFactory.ceoAddress.transfer(_cut);
        address newWill = new Will(recipient);
        deployedWills.push(newWill);
    }

    function getDeployedWills() public view returns (address[]) {
        return deployedWills;
    }
}
