// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

error Dochain__VerifyFailed();

/** @title Dochain Contract
 * @author José Piña
 * @notice Security file
 * @dev This implements the Openzeppelin library
 */

contract Dochain is
    ERC1155,
    Pausable,
    Ownable,
    ERC1155Burnable,
    ERC1155Supply,
    ERC1155URIStorage
{
    /* Type declarations */
    using ECDSA for bytes32;

    constructor(string memory tokenURI) ERC1155(tokenURI) {}

    function setURI(uint256 tokenId, string memory newuri) public {
        _setURI(tokenId, newuri);
    }

    function uri(uint256 tokenId)
        public
        view
        override(ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        return ERC1155URIStorage.uri(tokenId);
    }

    function readDocumentation(bytes32 message, bytes memory sign)
        public
        view
        whenNotPaused
        returns (bool)
    {
        if (_verify(message, sign, _msgSender())) {
            revert Dochain__VerifyFailed();
        }
        return true;
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public {
        _mintBatch(to, ids, amounts, data);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /* Internal Functions*/
    /// Verification function with signature
    function _verify(
        bytes32 data,
        bytes memory signature,
        address account
    ) internal pure returns (bool) {
        return data.toEthSignedMessageHash().recover(signature) == account;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
