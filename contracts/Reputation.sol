// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./AddrArrayLib.sol";

contract Reputation is ERC20 {
    using AddrArrayLib for AddrArrayLib.Addresses;
    mapping(address => AddrArrayLib.Addresses) private _pledge;

    constructor() ERC20("Synergetic Reputation Engine", "SYRP") {
        _mint(msg.sender, 1000 * 10**decimals());
    }

    function hasPledgeFor(address owner, address spender)
        public
        view
        returns (bool)
    {
        return _pledge[owner].exists(spender);
    }

    // adds a pledge to the input address for the sender of the transaction
    function addPledgeFor(address spender) public returns (bool) {
        _pledge[msg.sender].pushAddress(spender);
        return true;
    }

    function removePledgeFor(address spender) public returns (bool) {
        return _pledge[msg.sender].removeAddress(spender);
    }
}
