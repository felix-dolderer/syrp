// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./AddrArrayLib.sol";

struct CreditLine {
    uint256 maxCredit;
    uint256 usedCredit;
    address owner;
    address spender; // recipient of the credit line
    bool exists;
}

struct ProposedCreditLine {
    uint proposedDeduction;
    address owner;
    address spender;
}

contract Reputation is ERC20 {
    using AddrArrayLib for AddrArrayLib.Addresses;

    mapping(address => AddrArrayLib.Addresses) private _pledges;

    mapping(address => mapping(address => CreditLine)) private _creditLineMap;

    CreditLine[] private _creditLines;

    constructor() ERC20("Synergetic Reputation Engine", "SYRP") {
        _mint(msg.sender, 1000 * 10**decimals());
        //todo creditLines array initialisieren?
    }

    function hasPledgeFor(address owner, address spender)
        public
        view
        returns (bool)
    {
        return _pledges[owner].exists(spender);
    }

    // adds a pledge to the input address for the sender of the transaction
    function addPledgeFor(address spender) public returns (bool) {
        _pledges[msg.sender].pushAddress(spender);
        return true;
    }

    function removePledgeFor(address spender) public returns (bool) {
        return _pledges[msg.sender].removeAddress(spender);
    }

    function getCreditLine(address spender)
        public
        view
        returns (CreditLine memory)
    {
        return getCreditLine(msg.sender, spender);
    }

    function getCreditLine(address owner, address spender)
        internal
        view
        returns (CreditLine memory)
    {
        return _creditLineMap[owner][spender];
    }

    /**
    * Used to lock funds up by credit giver (msg.sender) to a certain person they trust, overriding existing credits!
    */
    function setCreditLine(address spender, uint256 amount)
        public
        returns (bool)
    {
        return setCreditLine(msg.sender, spender, amount);
    }

    function setCreditLine(
        address owner,
        address spender,
        uint256 maxCredit
    ) internal returns (bool) {
      CreditLine memory line;

      require(_creditLineMap[owner][spender].usedCredit <= maxCredit,
      'Cannot set credit line below amount that is already in use.');

      if(!_creditLineMap[owner][spender].exists) { //create new CreditLine
        line = CreditLine(maxCredit, 0, owner, spender, true);
        _creditLines.push(line);
        _creditLineMap[owner][spender] = line;
      } else { // update existing
        line = _creditLineMap[owner][spender];
        for (uint256 i = 0; i < _creditLines.length; i++) {
          if (_creditLines[i].owner == line.owner && _creditLines[i].spender == line.spender) {
              _creditLines[i].maxCredit = maxCredit;
              _creditLineMap[owner][spender] = _creditLines[i];
              continue;
          }
        }
      }

      return approve(spender, maxCredit);
    }

    function useCreditLine(
        address owner,
        address spender,
        uint256 creditUsed
    ) internal returns (bool) {
        spender = msg.sender;
        CreditLine memory creditLine = _creditLineMap[owner][spender];
        uint256 newUsedCredit = creditLine.usedCredit + creditUsed;

        require(newUsedCredit > creditLine.usedCredit);
        require(newUsedCredit > creditUsed);
        require(newUsedCredit <= creditLine.maxCredit);

        _creditLineMap[owner][spender].usedCredit = newUsedCredit;
        return true;
    }

    function transferCredits(ProposedCreditLine[] calldata usedCreditLines) public returns (bool) {
      // get closest link of creditlines to the msg.sender
      // transfer the amount through the creditLines up to the sender, update the usedCredit
      // return true when found and transfers initiated.
      // return false when no transfer found.

      // Required return value CreditLine[] with `proposedAmount`to transfer;
      for (uint i = 0; i < usedCreditLines.length; i++) {
        ProposedCreditLine calldata credit = usedCreditLines[i];
        transferFrom(credit.owner, credit.spender, credit.proposedDeduction);
        //update creditLines.
        for ( uint j = 0; j < _creditLines.length; j++) {
          if( _creditLines[j].owner == credit.owner && _creditLines[j].spender == credit.spender) {
            _creditLines[j].usedCredit += credit.proposedDeduction;
            _creditLineMap[credit.owner][credit.spender] = _creditLines[j];
            continue; 
          }
        }
      }
      return true;
    }

    function getAllCreditLines() public view returns (CreditLine[] memory) {
      return _creditLines;
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
        CreditLine memory creditLine = _creditLineMap[owner][spender];
        uint256 newUsedCredit = creditLine.usedCredit - repayment;

        require(newUsedCredit < creditLine.usedCredit);

        transferFrom(spender, owner, repayment);

        _creditLineMap[owner][spender].usedCredit = newUsedCredit;

        return true;
    }
}
