// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import "./interfaces/IERC20.sol";
import "./libraries/SafeMath.sol";

contract BlancoToken is IERC20 {
  using SafeMath for uint256;

  uint256 public _totalSupply = 10**13;
  string public name = 'Blanco Token';
  uint8 public constant decimals = 10;
  string public constant symbol = 'Blanco';
  address public highestBalanceAddress;


  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;


  constructor () {
    _balances[msg.sender] = _totalSupply;
    highestBalanceAddress = msg.sender;
    emit Transfer(address(0), msg.sender , _totalSupply);
  }

  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public override view returns (uint256) {
    return _balances[owner];
  }

  /**
  * Function to check the owner with the most amount of tokens.
  */
  function getHighestBalanceAddress() public view returns (address) {
    return highestBalanceAddress;
  }

  function changeTokenName(string memory newName) public returns (bool) {
    require(msg.sender == highestBalanceAddress, "Only the highest token holder can change the name.");
    name = newName;
    return true;
  }

  /**
  * Function to check the amount of tokens that an owner allowed to a spender.
  */
  function allowance(address owner, address spender) public override view returns (uint256){
    return _allowed[owner][spender];
  }

  function transfer(address to, uint256 value) public override returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);

    if (_balances[to] > _balances[highestBalanceAddress]) {
      highestBalanceAddress = to;
    }
    emit Transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public override returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function _transfer(address from, address to, uint value) private {
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    if (_balances[to] > _balances[highestBalanceAddress]) {
      highestBalanceAddress = to;
    }
    emit Transfer(from, to, value);
  }

  function transferFrom( address from, address to, uint256 value) public override returns (bool){
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  function increaseAllowance( address spender, uint256 addedValue ) public returns (bool){
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender,uint256 subtractedValue) public returns (bool){
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function mint(uint256 value) public returns (bool) {
      require(msg.sender == highestBalanceAddress, "Only the highest token holder can mint new tokens.");

      _totalSupply = _totalSupply.add(value);
      _balances[msg.sender] = _balances[msg.sender].add(value);

      emit Transfer(address(0), msg.sender, value);
      return true;
  }

  function burn(address to, uint256 value) public returns (bool) {
      require(to != address(0), "ERC20: burn from the zero address");
      require(msg.sender == highestBalanceAddress, "Only the highest token holder can punish and burn tokens.");
      require(value < _balances[to], "burn amount exceeds balance");

      _totalSupply = _totalSupply.sub(value);
      _balances[to] = _balances[to].sub(value);

      emit Transfer(to, address(0), value);
      return true;
  }

}