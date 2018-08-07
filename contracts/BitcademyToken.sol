pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";

contract BitcademyToken is PausableToken {
  string public constant name = "Bitcademy Gold";
  string public constant symbol = "BTMG";
  uint public constant decimals = 18;

  constructor(address _reserve,address _vestingAddress,uint _initial_supply) public{
    totalSupply_ = (_initial_supply*(10**decimals));
    balances[_vestingAddress]  = (totalSupply_.mul(15)).div(100);
    balances[_reserve] = (_initial_supply*(10**decimals)).sub(balances[_vestingAddress]);
    emit Transfer(this,_reserve,totalSupply_);
    emit Transfer(this,_vestingAddress,balances[_vestingAddress]);
  }
}
