pragma solidity ^0.5.6;

import "ds-test/test.sol";
import "mix-item-store/item_store_registry.sol";
import "mix-item-store/item_store_ipfs_sha256.sol";

import "./MixItemDagOneParent.sol";


contract ItemDagOneParentTest is DSTest {

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;
    ItemDagOneParent itemDag;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
        itemDag = new ItemDagOneParent(itemStoreRegistry);
    }

    function testControlAddChildAlreadyHasParent() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        bytes32 itemId1 = itemStore.create(bytes2(0x0001), hex"1234");
        itemDag.addChild(itemId0, itemStore, bytes2(0x0002));
        itemDag.addChild(itemId1, itemStore, bytes2(0x0003));
    }

    function testFailAddChildAlreadyHasParent() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        bytes32 itemId1 = itemStore.create(bytes2(0x0001), hex"1234");
        itemDag.addChild(itemId0, itemStore, bytes2(0x0002));
        itemDag.addChild(itemId1, itemStore, bytes2(0x0002));
    }

    function testControlAddChildParentNotExist() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemDag.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildParentNotExist() public {
        bytes32 itemId0 = hex"";
        itemDag.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testControlAddChildChildExists() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemDag.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildChildExists() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemStore.create(bytes2(0x0001), hex"1234");
        itemDag.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testAddChild() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");

        assertEq(itemDag.getChildCount(itemId0), 0);
        assertEq(itemDag.getAllChildIds(itemId0).length, 0);
        assert(!itemDag.getHasParent(itemId0));

        itemDag.addChild(itemId0, itemStore, bytes2(0x0001));
        bytes32 itemId1 = itemStore.create(bytes2(0x0001), hex"1234");

        assertEq(itemDag.getChildCount(itemId0), 1);
        bytes32[] memory childIds = itemDag.getAllChildIds(itemId0);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId1);
        assert(!itemDag.getHasParent(itemId0));

        assertEq(itemDag.getChildCount(itemId1), 0);
        assertEq(itemDag.getAllChildIds(itemId1).length, 0);
        assert(itemDag.getHasParent(itemId1));
        assertEq(itemDag.getParentId(itemId1), itemId0);

        itemDag.addChild(itemId0, itemStore, bytes2(0x0002));
        bytes32 itemId2 = itemStore.create(bytes2(0x0002), hex"1234");

        assertEq(itemDag.getChildCount(itemId0), 2);
        childIds = itemDag.getAllChildIds(itemId0);
        assertEq(childIds.length, 2);
        assertEq(childIds[0], itemId1);
        assertEq(childIds[1], itemId2);
        assert(!itemDag.getHasParent(itemId0));

        assertEq(itemDag.getChildCount(itemId1), 0);
        assertEq(itemDag.getAllChildIds(itemId1).length, 0);
        assert(itemDag.getHasParent(itemId1));
        assertEq(itemDag.getParentId(itemId1), itemId0);

        assertEq(itemDag.getChildCount(itemId2), 0);
        assertEq(itemDag.getAllChildIds(itemId2).length, 0);
        assert(itemDag.getHasParent(itemId2));
        assertEq(itemDag.getParentId(itemId2), itemId0);
    }

}
