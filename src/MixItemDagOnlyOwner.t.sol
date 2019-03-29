pragma solidity ^0.5.6;

import "ds-test/test.sol";
import "mix-item-store/item_store_registry.sol";
import "mix-item-store/item_store_ipfs_sha256.sol";

import "./MixItemDagOnlyOwner.sol";
import "./MixItemDagOnlyOwnerProxy.sol";


contract ItemDagOnlyOwnerTest is DSTest {

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;
    ItemDagOnlyOwner itemDagOnlyOwner;
    ItemDagOnlyOwnerProxy itemDagOnlyOwnerProxy;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
        itemDagOnlyOwner = new ItemDagOnlyOwner(itemStoreRegistry);
        itemDagOnlyOwnerProxy = new ItemDagOnlyOwnerProxy(itemDagOnlyOwner);
    }

    function testControlAddChildItemNotInUse() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildItemNotInUse() public {
        bytes32 itemId0 = hex"";
        itemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testControlAddChildItemDifferentOwner() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildItemDifferentOwner() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemDagOnlyOwnerProxy.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testControlAddChildChildExists() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testFailAddChildChildExists() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");
        itemStore.create(bytes2(0x0001), hex"1234");
        itemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
    }

    function testAddChild() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");

        assertEq(itemDagOnlyOwner.getChildCount(itemId0), 0);
        assertEq(itemDagOnlyOwner.getAllChildIds(itemId0).length, 0);
        assertEq(itemDagOnlyOwner.getParentCount(itemId0), 0);
        assertEq(itemDagOnlyOwner.getAllParentIds(itemId0).length, 0);

        itemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0001));
        bytes32 itemId1 = itemStore.create(bytes2(0x0001), hex"1234");

        assertEq(itemDagOnlyOwner.getChildCount(itemId0), 1);
        bytes32[] memory childIds = itemDagOnlyOwner.getAllChildIds(itemId0);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId1);
        assertEq(itemDagOnlyOwner.getParentCount(itemId0), 0);
        assertEq(itemDagOnlyOwner.getAllParentIds(itemId0).length, 0);

        assertEq(itemDagOnlyOwner.getChildCount(itemId1), 0);
        assertEq(itemDagOnlyOwner.getAllChildIds(itemId1).length, 0);
        assertEq(itemDagOnlyOwner.getParentCount(itemId1), 1);
        bytes32[] memory parentIds = itemDagOnlyOwner.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        itemDagOnlyOwner.addChild(itemId0, itemStore, bytes2(0x0002));
        bytes32 itemId2 = itemStore.create(bytes2(0x0002), hex"1234");

        assertEq(itemDagOnlyOwner.getChildCount(itemId0), 2);
        childIds = itemDagOnlyOwner.getAllChildIds(itemId0);
        assertEq(childIds.length, 2);
        assertEq(childIds[0], itemId1);
        assertEq(childIds[1], itemId2);
        assertEq(itemDagOnlyOwner.getParentCount(itemId0), 0);
        assertEq(itemDagOnlyOwner.getAllParentIds(itemId0).length, 0);

        assertEq(itemDagOnlyOwner.getChildCount(itemId1), 0);
        assertEq(itemDagOnlyOwner.getAllChildIds(itemId1).length, 0);
        assertEq(itemDagOnlyOwner.getParentCount(itemId1), 1);
        parentIds = itemDagOnlyOwner.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(itemDagOnlyOwner.getChildCount(itemId2), 0);
        assertEq(itemDagOnlyOwner.getAllChildIds(itemId2).length, 0);
        assertEq(itemDagOnlyOwner.getParentCount(itemId2), 1);
        parentIds = itemDagOnlyOwner.getAllParentIds(itemId2);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        itemDagOnlyOwner.addChild(itemId1, itemStore, bytes2(0x0003));
        itemDagOnlyOwner.addChild(itemId2, itemStore, bytes2(0x0003));
        bytes32 itemId3 = itemStore.create(bytes2(0x0003), hex"1234");

        assertEq(itemDagOnlyOwner.getChildCount(itemId0), 2);
        childIds = itemDagOnlyOwner.getAllChildIds(itemId0);
        assertEq(childIds.length, 2);
        assertEq(childIds[0], itemId1);
        assertEq(childIds[1], itemId2);
        assertEq(itemDagOnlyOwner.getParentCount(itemId0), 0);
        assertEq(itemDagOnlyOwner.getAllParentIds(itemId0).length, 0);

        assertEq(itemDagOnlyOwner.getChildCount(itemId1), 1);
        childIds = itemDagOnlyOwner.getAllChildIds(itemId1);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId3);
        assertEq(itemDagOnlyOwner.getParentCount(itemId1), 1);
        parentIds = itemDagOnlyOwner.getAllParentIds(itemId1);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(itemDagOnlyOwner.getChildCount(itemId2), 1);
        childIds = itemDagOnlyOwner.getAllChildIds(itemId2);
        assertEq(childIds.length, 1);
        assertEq(childIds[0], itemId3);
        assertEq(itemDagOnlyOwner.getParentCount(itemId2), 1);
        parentIds = itemDagOnlyOwner.getAllParentIds(itemId2);
        assertEq(parentIds.length, 1);
        assertEq(parentIds[0], itemId0);

        assertEq(itemDagOnlyOwner.getChildCount(itemId3), 0);
        assertEq(itemDagOnlyOwner.getAllChildIds(itemId3).length, 0);
        assertEq(itemDagOnlyOwner.getParentCount(itemId3), 2);
        parentIds = itemDagOnlyOwner.getAllParentIds(itemId3);
        assertEq(parentIds.length, 2);
        assertEq(parentIds[0], itemId1);
        assertEq(parentIds[1], itemId2);
    }

}
