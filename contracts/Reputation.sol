// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Reputation is ERC20 {
    uint storedData;

    constructor() ERC20("Synergetic Reputation Engine", "SYRP") {
      _mint(msg.sender, 1000 * 10 ** decimals());
    }

  function set(uint x) public {
    storedData = x;
  }

  function get() public view returns (uint) {
    return storedData;
  }
}
