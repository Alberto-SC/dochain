// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

error Dochain__VerifyFailed();
error Dochain__YouNotTheOwner();

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
    using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;

    enum TypeToken {
        directory,
        file
    }

    mapping(uint256 => TypeToken) public typeOfToken;
    mapping(uint256 => uint256) public relationToken;

    event MintSuccess(
        uint256 indexed idToken,
        bytes data,
        address indexed owner,
        TypeToken indexed tokenType
    );
    event SetURISuccess(uint256 indexed idToken, string indexed newURI);

    constructor(string memory tokenURI) ERC1155(tokenURI) {}

    function setURI(uint256 tokenId, string memory newuri) public {
        if (balanceOf(msg.sender, tokenId) > 0) {
            _setURI(tokenId, newuri);
            emit SetURISuccess(tokenId, newuri);
        } else {
            revert Dochain__YouNotTheOwner();
        }
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
            return true;
        } else {
            revert Dochain__VerifyFailed();
        }
    }

    function mint(
        address account,
        uint256 amount,
        bytes memory data,
        TypeToken tokenType,
        uint256 _relationToken
    ) public {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        relationToken[tokenId] = _relationToken;
        _mint(account, tokenId, amount, data);
        typeOfToken[tokenId] = tokenType;
        emit MintSuccess(tokenId, data, account, tokenType);
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
