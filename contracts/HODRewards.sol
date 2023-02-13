// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// Polygon (Matic) Mumbai Testnet Deployment
contract HODRewards is ERC721, ERC721Enumerable {
    mapping(uint256 => uint256) public scores;
    mapping(uint256 => string) public imageCIDs;
    mapping(uint256 => string) public levelImages;
    mapping(address => uint256) public ownedToken;
    string public description;
    string private hodrName;
    string private hodrSymbol;

    /**
     * Constructor
     *
     * Network: Polygon (Matic) Mumbai Testnet
     * levelImages: images for rewards NFT artwork
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _description
    ) ERC721(_name, _symbol) {
        hodrName = _name;
        hodrSymbol = _symbol;
        description = _description;
        levelImages[
            1
        ] = "ipfs://bafybeibwoldch6e4st64kl2gkrb6bdm4nz4c2afl25f23uuzsg6iyl2ky4";
        levelImages[
            2
        ] = "ipfs://bafybeiejetved5zq2if2q2p537x2gm46rdvxrmf7ylqtey2iqm5lewdlsy";
        levelImages[
            3
        ] = "ipfs://bafybeif27ap2tu4xxzpt5k4tp7lggxi6z73avibvmgse2ans2agexmeu2i";
        levelImages[
            4
        ] = "ipfs://bafybeia3jgtcy4wkereaxltas73qemnxefksej2irw2q3g2mfcnz4jcdka";
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        require(_exists(tokenId), "HODR: Non-Existent Token");
        string memory jsonData = string(
            abi.encodePacked(
                '{"name": "',
                hodrName,
                " #",
                Strings.toString(uint256(tokenId)),
                '", "description": "',
                description,
                '", "image": "',
                imageCIDs[tokenId]
            )
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    jsonData,
                                    '", "attributes": [{"trait_type": "score", "value": "',
                                    Strings.toString(scores[tokenId]),
                                    '"}]}'
                                )
                            )
                        )
                    )
                )
            );
    }

    /**
     * Mint rewards NFT with score attribute
     */
    function mint(uint256 _score) public {
        require(ownedToken[msg.sender] == 0, "Address already has a token.");
        uint256 newTokenId = totalSupply() + 1;
        _mint(msg.sender, newTokenId);
        scores[newTokenId] = _score;
        imageCIDs[newTokenId] = levelImages[
            (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
                4) + 1
        ];
        ownedToken[msg.sender] = newTokenId;
        emit LogNewToken(newTokenId, _score, msg.sender, imageCIDs[newTokenId]);
    }

    /**
     * Update rewards NFT with new score attribute
     */
    function updateScore(uint256 _tokenId, uint256 _score) public {
        require(
            msg.sender == ownerOf(_tokenId),
            "Only token owner can update score."
        );
        scores[_tokenId] = _score;
        emit LogNewScore(_tokenId, _score);
    }

    event LogNewToken(
        uint256 tokenId,
        uint256 score,
        address to,
        string imageCID
    );
    event LogNewScore(uint256 tokenId, uint256 score);

    /**
     * @dev {ERC721-_beforeTokenTransfer}
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /// @dev See ERC165: https://eips.ethereum.org/EIPS/eip-165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
