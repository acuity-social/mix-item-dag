pragma solidity ^0.5.9;

import "./MixItemDagOnlyOwner.sol";


/**
 * @title ItemDagOnlyOwner
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Maintains a directed acyclic graph of items where child items have the same owner as the parent.
 */
contract ItemDagOnlyOwnerProxy {

    ItemDagOnlyOwner itemDagOnlyOwner;

    /**
     * @param _itemDagOnlyOwner Real ItemDagOnlyOwner contract to proxy to.
     */
    constructor (ItemDagOnlyOwner _itemDagOnlyOwner) public {
        itemDagOnlyOwner = _itemDagOnlyOwner;
    }

    function addChild(bytes32 itemId, ItemStoreInterface childItemStore, bytes32 childNonce) external {
        itemDagOnlyOwner.addChild(itemId, childItemStore, childNonce);
    }

}
