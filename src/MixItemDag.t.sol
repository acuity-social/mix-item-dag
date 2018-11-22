pragma solidity ^0.5.0;

import "ds-test/test.sol";

import "./MixItemDag.sol";

import "../mix-item-store/src/item_store_registry.sol";


contract ItemDagTest is DSTest {

    ItemStoreRegistry itemStoreRegistry;
    ItemDag itemDag;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemDag = new ItemDag(itemStoreRegistry);
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
