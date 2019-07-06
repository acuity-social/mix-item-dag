pragma solidity ^0.5.9;

import "ds-test/test.sol";
import "mix-item-store/ItemStoreRegistry.sol";
import "mix-item-store/ItemStoreIpfsSha256.sol";

import "./MixItemDag.sol";


contract ItemDagTest is DSTest {

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;
    ItemDag itemDag;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
        itemDag = new ItemDag(itemStoreRegistry);
    }

    function testControlAddChildItemNotInUse() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemDag.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildItemNotInUse() public {
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
        assertEq(itemDag.getParentCount(itemId0), 0);
        assertEq(itemDag.getAllParentIds(itemId0).length, 0);

        itemDag.addChild(itemId0, itemStore, bytes2(0x0001));
        bytes32 itemId1 = itemStore.create(bytes2(0x0001), hex"1234");

        assertEq(itemDag.getChildCount(itemId0), 1);
        bytes32[] memory childIds = itemDag.getAllChildIds(itemId0);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId1);
        assertEq(itemDag.getParentCount(itemId0), 0);
        assertEq(itemDag.getAllParentIds(itemId0).length, 0);

        assertEq(itemDag.getChildCount(itemId1), 0);
        assertEq(itemDag.getAllChildIds(itemId1).length, 0);
        assertEq(itemDag.getParentCount(itemId1), 1);
        bytes32[] memory parentIds = itemDag.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        itemDag.addChild(itemId0, itemStore, bytes2(0x0002));
        bytes32 itemId2 = itemStore.create(bytes2(0x0002), hex"1234");

        assertEq(itemDag.getChildCount(itemId0), 2);
        childIds = itemDag.getAllChildIds(itemId0);
        assertEq(childIds.length, 2);
        assertEq(childIds[0], itemId1);
        assertEq(childIds[1], itemId2);
        assertEq(itemDag.getParentCount(itemId0), 0);
        assertEq(itemDag.getAllParentIds(itemId0).length, 0);

        assertEq(itemDag.getChildCount(itemId1), 0);
        assertEq(itemDag.getAllChildIds(itemId1).length, 0);
        assertEq(itemDag.getParentCount(itemId1), 1);
        parentIds = itemDag.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(itemDag.getChildCount(itemId2), 0);
        assertEq(itemDag.getAllChildIds(itemId2).length, 0);
        assertEq(itemDag.getParentCount(itemId2), 1);
        parentIds = itemDag.getAllParentIds(itemId2);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        itemDag.addChild(itemId1, itemStore, bytes2(0x0003));
        itemDag.addChild(itemId2, itemStore, bytes2(0x0003));
        bytes32 itemId3 = itemStore.create(bytes2(0x0003), hex"1234");

        assertEq(itemDag.getChildCount(itemId0), 2);
        childIds = itemDag.getAllChildIds(itemId0);
        assertEq(childIds.length, 2);
        assertEq(childIds[0], itemId1);
        assertEq(childIds[1], itemId2);
        assertEq(itemDag.getParentCount(itemId0), 0);
        assertEq(itemDag.getAllParentIds(itemId0).length, 0);

        assertEq(itemDag.getChildCount(itemId1), 1);
        childIds = itemDag.getAllChildIds(itemId1);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId3);
        assertEq(itemDag.getParentCount(itemId1), 1);
        parentIds = itemDag.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(itemDag.getChildCount(itemId2), 1);
        childIds = itemDag.getAllChildIds(itemId2);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId3);
        assertEq(itemDag.getParentCount(itemId2), 1);
        parentIds = itemDag.getAllParentIds(itemId2);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(itemDag.getChildCount(itemId3), 0);
        assertEq(itemDag.getAllChildIds(itemId3).length, 0);
        assertEq(itemDag.getParentCount(itemId3), 2);
        parentIds = itemDag.getAllParentIds(itemId3);
        assertEq(parentIds.length, 2);
        assertEq(parentIds[0], itemId1);
        assertEq(parentIds[1], itemId2);
    }

}
