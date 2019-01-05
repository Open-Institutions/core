pragma solidity ^0.4.25;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Enumerable.sol';

contract IdentitySystem is ERC721Enumerable {

  event LogInfo(string description);
  event LogWarn(string description);
  event LogError(string description);

  uint256 public dayCount = 1;

  uint256 public validityPeriod = (4 * 365) + 1;

  struct Identity {
    address signer;
    uint256 lastValidationDay;
    uint256 emissionDay;
  }

  Identity[] identities;

  mapping(address => bool) existing;

  modifier onlySigner(uint256 identityIndex) {
    require(isSigner(identityIndex, msg.sender));
    _;
  }

  modifier onlyValid(uint256 identityIndex) {
    require(isValid(identityIndex) == true);
    _;
  }

  modifier onlyNotValid(uint256 identityIndex) {
    require(isValid(identityIndex) == false);
    _;
  }

  function isValid(uint256 identityIndex) view public returns(bool) {
    return identities[identityIndex].lastValidationDay > 0 && dayCount + validityPeriod > identities[identityIndex].lastValidationDay;
  }

  function isSigner(uint256 identityIndex, address account) view public returns(bool) {
    require(account != address(0), "Invalid account address");
    return account == signerByIndex(identityIndex);
  }

  function signerByIndex(uint256 identityIndex) view public returns(address) {
    return identities[identityIndex].signer;
  }

  function issueNewIdentity() public {
    require(existing[msg.sender] == false);
    uint256 newIndex = identities.push(Identity(msg.sender, 0, dayCount));
    _mint(msg.sender, newIndex);
    existing[msg.sender] = true;
  }

  function recoverIdentity(uint256 identityIndex) public onlySigner(identityIndex) {
    _removeTokenFrom(ownerOf(identityIndex), identityIndex);
    _addTokenTo(msg.sender, identityIndex);
  }

}
