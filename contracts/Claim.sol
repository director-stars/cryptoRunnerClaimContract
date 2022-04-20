// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Claim  is Ownable{

    address public runToken;
    uint256 public rewardAmount;
    address public dev;
    mapping(address => uint256) public claimAmount;
    mapping(address => uint256) public rewardInfo;
    mapping(address => bool) public rewardAvailable;
    mapping(address => uint256) public totalClaimed;
    
    event WithDraw(address account, uint256 amount, uint256 time);

    modifier onlyAdminOrOwner {
      require(msg.sender == dev || msg.sender == owner());
      _;
    }

    constructor() {
        runToken = address(0x42AA843fEA178806F094164C84E88a212FB45F3E);
        rewardAmount = 1000 * 1e9;
        dev = address(0x67926b0C4753c42b31289C035F8A656D800cD9e7);
    }

    receive() external payable {}

    function addClaimUsers(address[] memory users, uint256 _claimAmount) external onlyAdminOrOwner {
        uint8 i;
        for(i; i < users.length; i ++){
            claimAmount[users[i]] = claimAmount[users[i]] + _claimAmount;
        }
    }

    function claim() external returns (bool){
        address user = msg.sender;
        require(claimAmount[user] != 0, "user doesn't have any claim");
        require(address(this).balance > 0, "not enough");
        (bool success,) = payable(user).call{value: claimAmount[user]}("");
        if(success){
            emit WithDraw(user, claimAmount[user], block.timestamp);
            totalClaimed[user] = totalClaimed[user] + claimAmount[user];
            claimAmount[user] = 0;
        }
        return success;
    }

    function addRewardUsers(address[] memory users) external onlyAdminOrOwner {
        uint8 i;
        for(i; i < users.length; i ++){
            rewardAvailable[users[i]] = true;
        }
    }

    function reward() external {
        address user = msg.sender;
        require(rewardAvailable[user] , "not available for reward");
        require(IERC20(runToken).balanceOf(address(this)) >= rewardAmount , "not enough token");
        if(rewardAvailable[user]){
            IERC20(runToken).transfer(user, rewardAmount);
            rewardInfo[user] = block.timestamp;
            rewardAvailable[user] = false;
        }
    }

    function resetUserRewardInfo(address user) external onlyAdminOrOwner {
        rewardInfo[user] = 0;
        rewardAvailable[user] = true;
    }

    function updateRewardAmount(uint256 _rewardAmount) external onlyAdminOrOwner {
        rewardAmount = _rewardAmount;    
    }

    function withdraw(address _account, uint256 _value) external onlyOwner {
        (bool success,) = payable(_account).call{value: _value}("");
    }

    function withdrawToken(address _account, uint256 _value) external onlyOwner {
        IERC20(runToken).transfer(_account, _value);
    }
}