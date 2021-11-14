// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./AddrArrayLib.sol";

struct CreditLine {
    uint256 maxCredit;
    uint256 usedCredit;
}

contract Reputation is ERC20 {
    using AddrArrayLib for AddrArrayLib.Addresses;
    mapping(address => AddrArrayLib.Addresses) private _pledge;
    mapping(address => mapping(address => CreditLine)) private _creditLine;

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

    function getCreditLine(address spender)
        public
        view
        returns (CreditLine memory)
    {
        return getCreditLine(msg.sender, spender);
    }

    function getCreditLine(address owner, address spender)
        public
        view
        returns (CreditLine memory)
    {
        return _creditLine[owner][spender];
    }

    function setCreditLine(address spender, uint256 maxCredit)
        public
        returns (bool)
    {
        return setCreditLine(msg.sender, spender, maxCredit);
    }

    function setCreditLine(
        address owner,
        address spender,
        uint256 maxCredit
    ) internal returns (bool) {
        _creditLine[owner][spender].maxCredit = maxCredit;
        return true;
    }

    function useCreditLine(address owner, uint256 creditUsed)
        public
        returns (bool)
    {
        return useCreditLine(owner, msg.sender, creditUsed);
    }

    function useCreditLine(
        address owner,
        address spender,
        uint256 creditUsed
    ) internal returns (bool) {
        CreditLine memory creditLine = _creditLine[owner][spender];
        uint256 newUsedCredit = creditLine.usedCredit + creditUsed;

        require(newUsedCredit > creditLine.usedCredit);
        require(newUsedCredit > creditUsed);
        require(newUsedCredit <= creditLine.maxCredit);

        _creditLine[owner][spender].usedCredit = newUsedCredit;
        return true;
    }

    function repayCredit(address owner, uint256 repayment)
        public
        returns (bool)
    {
        return repayCredit(owner, msg.sender, repayment);
    }

    function repayCredit(
        address owner,
        address spender,
        uint256 repayment
    ) internal returns (bool) {
        CreditLine memory creditLine = _creditLine[owner][spender];
        uint256 newUsedCredit = creditLine.usedCredit - repayment;

        require(newUsedCredit < creditLine.usedCredit);

        _creditLine[owner][spender].usedCredit = newUsedCredit;
        return true;
    }
}
