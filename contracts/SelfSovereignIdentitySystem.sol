pragma solidity ^0.4.25;

import "./lib/OraclizeAPI.sol";
import './IdentitySystem.sol';

contract SelfSovereignIdentitySystem is IdentitySystem, usingOraclize {
  using SafeMath for uint256;

  bytes32 private pendingQuery;
  uint256 private callbackGasPrice = 200000;
  uint256 private delay = 1 days;
  uint256 private randomBytes = 7;
  uint8 private daysBeforeWarn = 10;

  event NewCitizen(uint256 identityIndex);
  event ExpiredCitizen(uint256 identityIndex);

  event NewValidator(uint256 identityIndex);
  event ExpiredValidator(uint256 identityIndex);

  uint256[] allCitizen;
  mapping(uint256 => uint256) allCitizenIndex;

  mapping (uint256 => uint256) lastValidatorMandateDay;

  uint256 validatorCount;

  uint256 validityPeriodForValidator = 30 * 3;

  uint256 validatorCountGoal;

  bool stopped;

  constructor() public payable
  {
    require(msg.value > oraclize_getPrice("random", callbackGasPrice), "Amount of ETH not sufficent to start the clock");
    oraclize_setProof(proofType_Ledger); // sets the Ledger authenticity proof
    bytes32 newQueryId = oraclize_newRandomDSQuery(delay, 32, callbackGasPrice);
    dayCount = 1;
    pendingQuery = newQueryId;
    stopped = false;
  }

  modifier verifyCallback(bytes32 _queryId, string _result, bytes _proof)
  {
    require(msg.sender == oraclize_cbAddress(), "Invalid callback address");
    require(pendingQuery == _queryId, "Invalid callback queryId");
    require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1), "Invalid callback proof header");
    require(oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName()), "Invalid callback proof");
    _;
  }

  modifier whenStopped() {
    require(stopped = true);
    _;
  }

  modifier onlyValidator(uint256 _identityIndex) {
    require(isValidator(_identityIndex), "Invalid identity index");
    _;
  }

  function _isAdmissible(uint256 _identityIndex) view internal
    onlyValid(_identityIndex) returns (bool)
  {
      return dayCount + validityPeriodForValidator < identities[_identityIndex].lastValidationDay + validityPeriod;
  }

  function isCitizen(uint256 _identityIndex) view public returns (bool) {
    return allCitizenIndex[_identityIndex] > 0;
  }

  function isValidator(uint256 _identityIndex) view public returns (bool) {
    return lastValidatorMandateDay[_identityIndex] + validityPeriodForValidator > dayCount;
  }

  function validateCitizen(uint256 _validatorIndex, uint256 _identityIndex) public
    onlySigner(_validatorIndex)
    onlyValidator(_validatorIndex)
  {
    if (identities[_identityIndex].lastValidationDay == 0)
    {
      identities[_identityIndex].lastValidationDay = dayCount;
      allCitizenIndex[_identityIndex] = allCitizen.length;
      allCitizen.push(_identityIndex);
    } else {
      identities[_identityIndex].lastValidationDay = dayCount;
    }
  }

  function removeCitizen(uint256 identityIndex) public
    onlyNotValid(identityIndex)
  {
    // Reorg all citizen array
    uint256 tokenIndex = allCitizenIndex[identityIndex];
    uint256 lastTokenIndex = allCitizen.length.sub(1);
    uint256 lastToken = allCitizen[lastTokenIndex];

    allCitizen[tokenIndex] = lastToken;
    allCitizen[lastTokenIndex] = 0;

    allCitizen.length--;
    allCitizenIndex[identityIndex] = 0;
    allCitizenIndex[lastToken] = tokenIndex;
  }

  function _randomlyPickCitizen(bytes _randomSeed) view private returns(uint256){
    for(uint8 i = 0 ; i < 5 ; i++)
    {
      _randomSeed[0]=bytes1(i);
      uint256 pickedIndex = uint256(keccak256(_randomSeed)) % allCitizen.length;
      if (_isAdmissible(allCitizen[pickedIndex]))
        return allCitizenIndex[pickedIndex];
    }
    return 0;
  }

  function __callback(bytes32 _queryId, string _result, bytes _proof) public
      verifyCallback(_queryId, _result, _proof)
  {
    _executeDailyProcess(bytes(_result));
    _scheduleNextDailyProcess();
  }

  function _executeDailyProcess(bytes _randomSeed) private {
    dayCount = dayCount + 1;
    uint256 pickedIndex;
    if (validatorCountGoal > validatorCount) {
      pickedIndex = _randomlyPickCitizen(_randomSeed);
      if(pickedIndex>0)
      {
        lastValidatorMandateDay[pickedIndex] = dayCount;
        emit LogInfo("New validator picked");
      }
    }
  }

  function _scheduleNextDailyProcess() private {
    if (oraclize_getPrice("random", callbackGasPrice) > address(this).balance) {
      emit LogError("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      stopped = true;
    } else {
      if (oraclize_getPrice("random", callbackGasPrice) * daysBeforeWarn > address(this).balance)
        emit LogWarn("Consider to add some ETH to cover for the query fee");
      emit LogInfo("Oraclize query was sent, standing by for the answer..");
      bytes32 newQueryId = oraclize_newRandomDSQuery(delay, 32, callbackGasPrice);
      pendingQuery = newQueryId;
    }
  }

  function restart() public payable whenStopped()
  {
    require(msg.value > oraclize_getPrice("random", callbackGasPrice), "Amount of ETH not sufficent to restart the clock");
    bytes32 newQueryId = oraclize_newRandomDSQuery(delay, 32, callbackGasPrice);
    pendingQuery = newQueryId;
    stopped = false;
  }

}
