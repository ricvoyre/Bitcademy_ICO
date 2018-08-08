pragma solidity ^0.4.23;

import "./BitcademyToken.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * owner.
 */
contract BitcademyVesting is Ownable {
  using SafeMath for uint256;

  event Released(uint256 amount);

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;
  uint256 public interval;

  uint256 public constant ReleaseCap = 150000000000000000000000000;

  mapping (address=>bool) public members;
  mapping (address =>uint) public numReleases;
  mapping (address => uint) public nextRelease;
  uint256 public noOfMembers;
  uint256 public released;
  //uint256 public standardQuantity;
  uint public constant Releases = 18;
  /**
   * @dev Creates a vesting contract that vests its balance of any BitcademyToken token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _start the time (as Unix time) at which point vesting starts
   * @param _duration duration in seconds of the period in which the tokens will vest
   */
  constructor(
    uint256 _start,
    uint256 _cliff,
    uint256 _duration,
    uint256 _interval
  )
    public
  {
    require(_cliff <= _duration);

    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
    interval = _interval;
  }

  modifier onlyMember(address _memberAddress) {
    require(members[_memberAddress] == true);
      _;
  }

  function addMember(address _member) public onlyOwner {
      require(members[_member] == false);
      members[_member] = true;
      noOfMembers = noOfMembers.add(1);
  }

  function removeMember(address _member) public onlyOwner {
      require(members[_member] == true);
      members[_member] = false;
      noOfMembers = noOfMembers.sub(1);
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param _token BitcademyToken token which is being vested
   */
  function release(BitcademyToken _token, address _member) onlyMember(_member) public {
    uint256 unreleased = releasableAmount(_token);

    require(unreleased > 0);

    require(numReleases[_member] <= Releases);
    if (numReleases[_member] == 0){
     nextRelease[_member] = interval.add(cliff);
   }
    require(nextRelease[_member] >= block.timestamp);
    released = released.add(unreleased);
    unreleased = ReleaseCap.div(noOfMembers.mul(Releases));
    //unreleased =  unreleased.div(noOfMembers);

    _token.transfer(_member, unreleased);

    numReleases[_member]++;
    nextRelease[_member] = nextRelease[_member].add(interval);

    emit Released(unreleased);
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param _token BitcademyToken token which is being vested
   */
  function releasableAmount(BitcademyToken _token) public view returns (uint256) {
    return vestedAmount(_token).sub(released);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param _token BitcademyToken token which is being vested
   */
  function vestedAmount(BitcademyToken _token) public view returns (uint256) {
    uint256 currentBalance = _token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released);

    if (block.timestamp < cliff) {
      return 0;
    } else if (block.timestamp >= start.add(duration)) {
      return totalBalance;
    } else {
      return totalBalance.mul(block.timestamp.sub(start)).div(duration);
    }
  }
}
