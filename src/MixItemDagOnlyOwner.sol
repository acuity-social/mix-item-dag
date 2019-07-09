pragma solidity ^0.5.10;

import "./MixItemDag.sol";


/**
 * @title ItemDagOnlyOwner
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Maintains a directed acyclic graph of items where child items have the same owner as the parent.
 */
contract ItemDagOnlyOwner is ItemDag {

    /**
     * @param _itemStoreRegistry Address of the ItemStoreRegistry contract.
     */
    constructor(ItemStoreRegistry _itemStoreRegistry) ItemDag(_itemStoreRegistry) public {}

    /**
     * @dev Add a child to an item. The child must not exist yet.
     * @param itemId itemId of the parent. Must have same owner.
     * @param childItemStore The ItemStore contract that will contain the child.
     * @param childNonce The nonce that will be used to create the child.
     */
    function addChild(bytes32 itemId, ItemStoreInterface childItemStore, bytes32 childNonce) external {
        // Get parent ItemStore.
        ItemStoreInterface itemStore = itemStoreRegistry.getItemStore(itemId);
        // Ensure the parent exists.
        require (itemStore.getInUse(itemId), "Parent does not exist.");
        // Ensure the child has the same owner as the parent.
        require (itemStore.getOwner(itemId) == msg.sender, "Child has different owner than parent.");
        // Get the child itemId. Ensure it does not exist.
        bytes32 childId = childItemStore.getNewItemId(msg.sender, childNonce);

        // Get parent state.
        ItemState storage state = itemState[itemId];
        // Get the index of the new child.
        uint i = state.childCount;
        // Store the childId.
        itemChildIds[itemId][i] = childId;
        // Increment the child count.
        state.childCount = uint128(i + 1);
        // Log the new child.
        emit AddChild(itemId, msg.sender, childId, i);

        // Get child state.
        state = itemState[childId];
        // Get the index of the new parent.
        i = state.parentCount;
        // Store the parentId.
        itemParentIds[childId][i] = itemId;
        // Increment the child count.
        state.parentCount = uint128(i + 1);
    }

}
