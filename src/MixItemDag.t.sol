pragma solidity ^0.5.10;

import "ds-test/test.sol";
import "mix-item-store/MixItemStoreRegistry.sol";
import "mix-item-store/MixItemStoreIpfsSha256.sol";

import "./MixItemDag.sol";


contract MixItemDagTest is DSTest {

    MixItemStoreRegistry itemStoreRegistry;
    MixItemStoreIpfsSha256 itemStore;
    MixItemDag mixItemDag;

    function setUp() public {
        itemStoreRegistry = new MixItemStoreRegistry();
        itemStore = new MixItemStoreIpfsSha256(itemStoreRegistry);
        mixItemDag = new MixItemDag(itemStoreRegistry);
    }

    function testControlAddChildItemNotInUse() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        mixItemDag.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildItemNotInUse() public {
        bytes32 itemId0 = hex"";
        mixItemDag.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testControlAddChildChildExists() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        mixItemDag.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildChildExists() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemStore.create(bytes2(0x0001), hex"1234");
        mixItemDag.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testAddChild() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");

        assertEq(mixItemDag.getChildCount(itemId0), 0);
        assertEq(mixItemDag.getAllChildIds(itemId0).length, 0);
        assertEq(mixItemDag.getParentCount(itemId0), 0);
        assertEq(mixItemDag.getAllParentIds(itemId0).length, 0);

        mixItemDag.addChild(itemId0, itemStore, bytes2(0x0001));
        bytes32 itemId1 = itemStore.create(bytes2(0x0001), hex"1234");

        assertEq(mixItemDag.getChildCount(itemId0), 1);
        bytes32[] memory childIds = mixItemDag.getAllChildIds(itemId0);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId1);
        assertEq(mixItemDag.getParentCount(itemId0), 0);
        assertEq(mixItemDag.getAllParentIds(itemId0).length, 0);

        assertEq(mixItemDag.getChildCount(itemId1), 0);
        assertEq(mixItemDag.getAllChildIds(itemId1).length, 0);
        assertEq(mixItemDag.getParentCount(itemId1), 1);
        bytes32[] memory parentIds = mixItemDag.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        mixItemDag.addChild(itemId0, itemStore, bytes2(0x0002));
        bytes32 itemId2 = itemStore.create(bytes2(0x0002), hex"1234");

        assertEq(mixItemDag.getChildCount(itemId0), 2);
        childIds = mixItemDag.getAllChildIds(itemId0);
        assertEq(childIds.length, 2);
        assertEq(childIds[0], itemId1);
        assertEq(childIds[1], itemId2);
        assertEq(mixItemDag.getParentCount(itemId0), 0);
        assertEq(mixItemDag.getAllParentIds(itemId0).length, 0);

        assertEq(mixItemDag.getChildCount(itemId1), 0);
        assertEq(mixItemDag.getAllChildIds(itemId1).length, 0);
        assertEq(mixItemDag.getParentCount(itemId1), 1);
        parentIds = mixItemDag.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(mixItemDag.getChildCount(itemId2), 0);
        assertEq(mixItemDag.getAllChildIds(itemId2).length, 0);
        assertEq(mixItemDag.getParentCount(itemId2), 1);
        parentIds = mixItemDag.getAllParentIds(itemId2);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        mixItemDag.addChild(itemId1, itemStore, bytes2(0x0003));
        mixItemDag.addChild(itemId2, itemStore, bytes2(0x0003));
        bytes32 itemId3 = itemStore.create(bytes2(0x0003), hex"1234");

        assertEq(mixItemDag.getChildCount(itemId0), 2);
        childIds = mixItemDag.getAllChildIds(itemId0);
        assertEq(childIds.length, 2);
        assertEq(childIds[0], itemId1);
        assertEq(childIds[1], itemId2);
        assertEq(mixItemDag.getParentCount(itemId0), 0);
        assertEq(mixItemDag.getAllParentIds(itemId0).length, 0);

        assertEq(mixItemDag.getChildCount(itemId1), 1);
        childIds = mixItemDag.getAllChildIds(itemId1);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId3);
        assertEq(mixItemDag.getParentCount(itemId1), 1);
        parentIds = mixItemDag.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(mixItemDag.getChildCount(itemId2), 1);
        childIds = mixItemDag.getAllChildIds(itemId2);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId3);
        assertEq(mixItemDag.getParentCount(itemId2), 1);
        parentIds = mixItemDag.getAllParentIds(itemId2);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(mixItemDag.getChildCount(itemId3), 0);
        assertEq(mixItemDag.getAllChildIds(itemId3).length, 0);
        assertEq(mixItemDag.getParentCount(itemId3), 2);
        parentIds = mixItemDag.getAllParentIds(itemId3);
        assertEq(parentIds.length, 2);
        assertEq(parentIds[0], itemId1);
        assertEq(parentIds[1], itemId2);
    }

}
