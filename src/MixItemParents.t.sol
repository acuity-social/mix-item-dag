pragma solidity ^0.5.0;

import "ds-test/test.sol";

import "./MixItemParents.sol";

contract MixItemParentsTest is DSTest {
    MixItemParents parents;

    function setUp() public {
        parents = new MixItemParents();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
