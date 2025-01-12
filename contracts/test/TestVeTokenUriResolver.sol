// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './helpers/TestBaseWorkflow.t.sol';
import '../interfaces/IJBVeTokenUriResolver.sol';

contract JBveTokenUriResolverTests is TestBaseWorkflow {
  //*********************************************************************//
  // --------------------- private stored properties ------------------- //
  //*********************************************************************//
  JBveBanny private _jbveBanny;
  JBVeTokenUriResolver private _jbveTokenUriResolver;
  JBTokenStore private _jbTokenStore;
  JBController private _jbController;
  JBOperatorStore private _jbOperatorStore;
  uint256 private _projectId;
  address private _projectOwner;
  uint256[] _lockDurationOptions = new uint256[](3);

  //*********************************************************************//
  // --------------------------- test setup ---------------------------- //
  //*********************************************************************//
  function setUp() public override {
    // calling before each for TestBaseWorkflow
    super.setUp();
    // fetching instances deployed in the base workflow file
    _projectId = projectID();
    _jbTokenStore = jbTokenStore();
    _jbOperatorStore = jbOperatorStore();
    _jbveTokenUriResolver = jbveTokenUriResolver();
    _jbController = jbController();

    _lockDurationOptions[0] = 864000;
    _lockDurationOptions[1] = 2160000;
    _lockDurationOptions[2] = 8640000;

    // JBveBanny
    _jbveBanny = new JBveBanny(
      _projectId,
      'Banny',
      'Banny',
      IJBVeTokenUriResolver(address(_jbveTokenUriResolver)),
      IJBTokenStore(address(_jbTokenStore)),
      IJBOperatorStore(address(_jbOperatorStore)),
      _lockDurationOptions
    );
  }

  function testConstructor() public {
    // assertion checks for constructor code
    assertEq(address(_jbTokenStore.tokenOf(_projectId)), address(_jbveBanny.token()));
    assertEq(address(_jbveTokenUriResolver), address(_jbveBanny.uriResolver()));
    assertEq(_projectId, _jbveBanny.projectId());
    assertEq(_lockDurationOptions[0], _jbveBanny.lockDurationOptions()[0]);
  }

  function mintIJBTokens() public returns (IJBToken) {
    IJBToken _token = _jbTokenStore.tokenOf(_projectId);
    _projectOwner = projectOwner();
    vm.startPrank(_projectOwner);
    _jbController.mintTokensOf(_projectId, 100 ether, _projectOwner, 'Test Memo', true, true);
    _token.approve(_projectId, address(_jbveBanny), 10 ether);
    return _token;
  }

  function testJBveTokenUriResolver() public view {
    string memory uri = _jbveTokenUriResolver.tokenURI(
      0,
      1000000000000000000000, // 1000 Tokens
      _lockDurationOptions[1], // 50 Days
      0,
      _lockDurationOptions
    );
    string memory derived = string(
      abi.encodePacked(
        'ipfs://QmSCaNi3VeyrV78qWiDgxdkJTUB7yitnLKHsPHudguc9kv/',
        Strings.toString(10 * 5 + 2)
      )
    );
    assert(keccak256(bytes(uri)) == keccak256(bytes(derived)));
  }
}
