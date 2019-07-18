pragma solidity ^0.5.10;

import "ds-test/test.sol";
import "mix-item-store/ItemStoreRegistry.sol";
import "mix-item-store/ItemStoreIpfsSha256.sol";

import "./MixItemDagOnlyOwner.sol";
import "./MixItemDagOnlyOwnerProxy.sol";


contract MixItemDagOnlyOwnerTest is DSTest {

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;
    MixItemDagOnlyOwner mixItemDagOnlyOwner;
    MixItemDagOnlyOwnerProxy mixItemDagOnlyOwnerProxy;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
        mixItemDagOnlyOwner = new MixItemDagOnlyOwner(itemStoreRegistry);
        mixItemDagOnlyOwnerProxy = new MixItemDagOnlyOwnerProxy(mixItemDagOnlyOwner);
    }

    function testControlAddChildItemNotInUse() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        mixItemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildItemNotInUse() public {
        bytes32 itemId0 = hex"";
        mixItemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testControlAddChildItemDifferentOwner() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        mixItemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildItemDifferentOwner() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        mixItemDagOnlyOwnerProxy.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testControlAddChildChildExists() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        mixItemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildChildExists() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemStore.create(bytes2(0x0001), hex"1234");
        mixItemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testAddChild() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");

        assertEq(mixItemDagOnlyOwner.getChildCount(itemId0), 0);
        assertEq(mixItemDagOnlyOwner.getAllChildIds(itemId0).length, 0);
        assertEq(mixItemDagOnlyOwner.getParentCount(itemId0), 0);
        assertEq(mixItemDagOnlyOwner.getAllParentIds(itemId0).length, 0);

        mixItemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
        bytes32 itemId1 = itemStore.create(bytes2(0x0001), hex"1234");

        assertEq(mixItemDagOnlyOwner.getChildCount(itemId0), 1);
        bytes32[] memory childIds = mixItemDagOnlyOwner.getAllChildIds(itemId0);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId1);
        assertEq(mixItemDagOnlyOwner.getParentCount(itemId0), 0);
        assertEq(mixItemDagOnlyOwner.getAllParentIds(itemId0).length, 0);

        assertEq(mixItemDagOnlyOwner.getChildCount(itemId1), 0);
        assertEq(mixItemDagOnlyOwner.getAllChildIds(itemId1).length, 0);
        assertEq(mixItemDagOnlyOwner.getParentCount(itemId1), 1);
        bytes32[] memory parentIds = mixItemDagOnlyOwner.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        mixItemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0002));
        bytes32 itemId2 = itemStore.create(bytes2(0x0002), hex"1234");

        assertEq(mixItemDagOnlyOwner.getChildCount(itemId0), 2);
        childIds = mixItemDagOnlyOwner.getAllChildIds(itemId0);
        assertEq(childIds.length, 2);
        assertEq(childIds[0], itemId1);
        assertEq(childIds[1], itemId2);
        assertEq(mixItemDagOnlyOwner.getParentCount(itemId0), 0);
        assertEq(mixItemDagOnlyOwner.getAllParentIds(itemId0).length, 0);

        assertEq(mixItemDagOnlyOwner.getChildCount(itemId1), 0);
        assertEq(mixItemDagOnlyOwner.getAllChildIds(itemId1).length, 0);
        assertEq(mixItemDagOnlyOwner.getParentCount(itemId1), 1);
        parentIds = mixItemDagOnlyOwner.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(mixItemDagOnlyOwner.getChildCount(itemId2), 0);
        assertEq(mixItemDagOnlyOwner.getAllChildIds(itemId2).length, 0);
        assertEq(mixItemDagOnlyOwner.getParentCount(itemId2), 1);
        parentIds = mixItemDagOnlyOwner.getAllParentIds(itemId2);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        mixItemDagOnlyOwner.addChild(itemId1, itemStore, bytes2(0x0003));
        mixItemDagOnlyOwner.addChild(itemId2, itemStore, bytes2(0x0003));
        bytes32 itemId3 = itemStore.create(bytes2(0x0003), hex"1234");

        assertEq(mixItemDagOnlyOwner.getChildCount(itemId0), 2);
        childIds = mixItemDagOnlyOwner.getAllChildIds(itemId0);
        assertEq(childIds.length, 2);
        assertEq(childIds[0], itemId1);
        assertEq(childIds[1], itemId2);
        assertEq(mixItemDagOnlyOwner.getParentCount(itemId0), 0);
        assertEq(mixItemDagOnlyOwner.getAllParentIds(itemId0).length, 0);

        assertEq(mixItemDagOnlyOwner.getChildCount(itemId1), 1);
        childIds = mixItemDagOnlyOwner.getAllChildIds(itemId1);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId3);
        assertEq(mixItemDagOnlyOwner.getParentCount(itemId1), 1);
        parentIds = mixItemDagOnlyOwner.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(mixItemDagOnlyOwner.getChildCount(itemId2), 1);
        childIds = mixItemDagOnlyOwner.getAllChildIds(itemId2);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId3);
        assertEq(mixItemDagOnlyOwner.getParentCount(itemId2), 1);
        parentIds = mixItemDagOnlyOwner.getAllParentIds(itemId2);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(mixItemDagOnlyOwner.getChildCount(itemId3), 0);
        assertEq(mixItemDagOnlyOwner.getAllChildIds(itemId3).length, 0);
        assertEq(mixItemDagOnlyOwner.getParentCount(itemId3), 2);
        parentIds = mixItemDagOnlyOwner.getAllParentIds(itemId3);
        assertEq(parentIds.length, 2);
        assertEq(parentIds[0], itemId1);
        assertEq(parentIds[1], itemId2);
    }

}
