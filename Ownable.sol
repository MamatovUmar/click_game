// SPDX-License-Identifier: MIT
pragma solidity 0.5.12;

contract Ownable {

    address payable internal _owner;

    constructor() internal {
        require(msg.sender != address(0));
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Not owner");
        _;
    }

    function isOwner() internal view returns (bool) {
        return msg.sender == _owner;
    }
    
}