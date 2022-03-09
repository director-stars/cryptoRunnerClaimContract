// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Claim  is Ownable{

    address runToken;
    mapping(address => uint256) claimAmount;
    event WithDraw(address account, uint256 amount, uint256 time);

    constructor() {
        runToken = address(0x42AA843fEA178806F094164C84E88a212FB45F3E);
    }

    receive() external payable {}

    function addClaimUsers(address[] memory users, uint256 _claimAmount) public onlyOwner {
        uint8 i;
        for(i; i < users.length; i ++){
            claimAmount[users[i]] = claimAmount[users[i]] + _claimAmount;
        }
    }

    function claim(address user) public returns (bool){
        require(msg.sender == user, "not user");
        require(claimAmount[msg.sender] != 0, "user doesn't have any claim");
        require(address(this).balance > 0, "not enough");
        (bool success,) = payable(user).call{value: claimAmount[user]}("");
        if(success){
            emit WithDraw(user, claimAmount[user], block.timestamp);
            claimAmount[user] = 0;
        }
        return success;
    }
}