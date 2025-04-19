// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.26;

//import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";

contract perpetuals {
    // 从 Solidity 0.8.0 开始，整数溢出检测已内置，无需依赖 SafeMath
    // using SafeMath for uint256;



    mapping(address => LongItem) longPool; // 
    address[] users;

    struct LongItem {
        address userAddr;
        uint8 rate; // guangan
        uint256 number; // goumai de BTC shuliang 
        uint256 buyPrice; // goumai de jiage
        uint256 outPrice; // baocang de jiage       
    }

    function benifit(address user, uint256 currentPrice) private{
        LongItem memory item = longPool[msg.sender];
        require(longPool[msg.sender].userAddr != address(0)); // buweikong
        
        uint256 benifitValue = item.number*item.rate*(currentPrice - item.buyPrice); // might be negtive or positive
        require(benifitValue > 0);

        // change effect check
        longPool[msg.sender] = LongItem(address(0),0,0,0,0);
        (bool success,) = payable(msg.sender).call{value: benifitValue/getETHPrice()}("");// might divide a zero 
        require(success, "转账失败");
    }

    function setLong(uint _rate, uint256 _btcNum, uint256 _buyPrice) external payable {
        require(longPool[msg.sender].userAddr == address(0),"user already exist"); // todo how to tell a map has a empty value
        require((_rate == 2 || _rate ==10 || _rate == 25 || _rate ==50),"invalid rate"); // yanzheng ganggan 
        require(_btcNum*_buyPrice == msg.value * getETHPrice(),"Insufficient ETH sent");
        // 
        longPool[msg.sender] = LongItem({
            userAddr: msg.sender,
            rate: _rate,
            number: _btcNum,
            buyPrice: _buyPrice,
            outPrice: _buyPrice - _buyPrice/_rate
        });
        users.push(msg.sender);

    }


    function getETHPrice() private pure returns(uint256){
        // return current price of per wei
        return 123456;
    }

    function getBTCPrice() private pure returns(uint256){
        // return current price of per wei
        return 123456;
    }

    function out() external {

        for(uint256 i = 0; i < users.length; i ++){
            LongItem memory item  = longPool[users[i]];
            if(getBTCPrice() <= item.outPrice ){
                // out 
                longPool[item.userAddr] = LongItem(address(0),0,0,0,0);
                users[i] = users[users.length-1];
                users.pop();
                i--;
                // array remove
            }
        }
    
    }

}