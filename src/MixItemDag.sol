pragma solidity ^0.5.0;

import "../mix-item-store/src/item_store_interface.sol";
import "../mix-item-store/src/item_store_registry.sol";


/**
 * @title ItemDag
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Maintains a directed acyclic graph of items.
 */
contract ItemDag {

    /**
     * @dev Single slot structure of item state.
     */
    struct ItemState {
        uint128 childCount;      // Number of children.
        uint128 parentCount;     // Number of parents.
    }

    /**
     * @dev Mapping of itemId to item state.
     */
    mapping (bytes32 => ItemState) itemState;

    /**
     * @dev Mapping of itemId to mapping of index to child itemId.
     */
    mapping (bytes32 => mapping(uint => bytes32)) itemChildIds;

    /**
     * @dev Mapping of itemId to mapping of index to parent itemId.
     */
    mapping (bytes32 => mapping(uint => bytes32)) itemParentIds;

    /**
     * @dev ItemStoreRegistry contract.
     */
    ItemStoreRegistry itemStoreRegistry;

    /**
     * @dev A child item has been attached to an item.
     * @param parentId itemId of the parent.
     * @param owner owner of the parent.
     * @param childId itemId of the child.
     * @param i Index of the new child.
     */
    event AddChild(bytes32 indexed parentId, address indexed owner, bytes32 childId, uint i);

    /**
     * @dev Revert if a specific item child does not exist.
     * @param itemId itemId of the item.
     * @param i Index of the child.
     */
    modifier childExists(bytes32 itemId, uint i) {
        require (i < itemState[itemId].childCount);
        _;
    }

    /**
     * @dev Revert if a specific item parent does not exist.
     * @param itemId itemId of the item.
     * @param i Index of the parent.
     */
    modifier parentExists(bytes32 itemId, uint i) {
        require (i < itemState[itemId].parentCount);
        _;
    }

    /**
     * @param _itemStoreRegistry Address of the ItemStoreRegistry contract.
     */
    constructor(ItemStoreRegistry _itemStoreRegistry) public {
        // Store the address of the ItemStoreRegistry contract.
        itemStoreRegistry = _itemStoreRegistry;
    }

    function addChild(bytes32 parentId, ItemStoreInterface childItemStore, bytes32 childNonce) external {
        // Ensure the parent exists.
        require(itemStoreRegistry.getItemStore(parentId).getInUse(parentId));
        // Get the child itemId. Ensure it does not exist.
        bytes32 childId = childItemStore.getNewItemId(msg.sender, childNonce);

        // Get parent state.
        ItemState storage parentState = itemState[parentId];
        // Get the index of the new child.
        uint i = parentState.childCount;
        // Store the childId.
        itemChildIds[parentId][i] = childId;
        // Increment the child count.
        parentState.childCount = uint128(i + 1);
        // Log the new child.
        emit AddChild(parentId, msg.sender, childId, i);

        // Get child state.
        ItemState storage childState = itemState[childId];
        // Get the index of the new parent.
        i = childState.parentCount;
        // Store the parentId.
        itemParentIds[childId][i] = parentId;
        // Increment the child count.
        childState.parentCount = uint128(i + 1);
    }

    /**
     * @dev Get the number of children an item has.
     * @param itemId itemId of the item.
     * @return How many children the item has.
     */
    function getChildCount(bytes32 itemId) external view returns (uint) {
        return itemState[itemId].childCount;
    }

    /**
     * @dev Get a specific child.
     * @param itemId itemId of the item.
     * @param i Index of the child.
     * @return itemId of the child.
     */
    function getChildId(bytes32 itemId, uint i) external view childExists(itemId, i) returns (bytes32) {
        return itemChildIds[itemId][i];
    }

    /**
     * @dev Get all of an item's children.
     * @param itemId itemId of the item.
     * @return itemIds of the children.
     */
    function getAllChildIds(bytes32 itemId) external view returns (bytes32[] memory childIds) {
        uint count = itemState[itemId].childCount;
        childIds = new bytes32[](count);
        for (uint i = 0; i < count; i++) {
            childIds[i] = itemChildIds[itemId][i];
        }
    }

    /**
     * @dev Get the number of parents an item has.
     * @param itemId itemId of the item.
     * @return How many parents the item has.
     */
    function getParentCount(bytes32 itemId) external view returns (uint) {
        return itemState[itemId].parentCount;
    }

    /**
     * @dev Get a specific parent.
     * @param itemId itemId of the item.
     * @param i Index of the parent.
     * @return itemId of the parent.
     */
    function getParentId(bytes32 itemId, uint i) external view parentExists(itemId, i) returns (bytes32) {
        return itemParentIds[itemId][i];
    }

    /**
     * @dev Get all of an item's parents.
     * @param itemId itemId of the item.
     * @return itemIds of the parents.
     */
    function getAllParentIds(bytes32 itemId) external view returns (bytes32[] memory parentIds) {
        uint count = itemState[itemId].parentCount;
        parentIds = new bytes32[](count);
        for (uint i = 0; i < count; i++) {
            parentIds[i] = itemParentIds[itemId][i];
        }
    }

}