```solidity
pragma solidity ^0.8.13;
import "hardhat/console.sol";

/// @title A contract for generating and managing NFT genomes
contract NFTGenome {
    /// @notice Mapping of address to genome value
    mapping(address => uint) private genomes;

    /// @notice Struct for NFT metadata properties
    struct Metadata {
        uint256 bgColor;
        uint256 bgEffect;
        uint256 wings;
        uint256 skinColor;
        uint256 skinPattern;
        uint256 body;
        uint256 mouth;
        uint256 eyes;
        uint256 hat;
        uint256 pet;
        uint256 accessory;
        uint256 border;
    }

    /// @notice Enum for ordering NFT metadata properties
    enum PropertyOrder {
        bgColor,
        bgEffect,
        wings,
        skinColor,
        skinPattern,
        body,
        mouth,
        eyes,
        hat,
        pet,
        accessory,
        border
    }

    /// @notice Adds a genome value for a given owner
    /// @param owner The address of the genome owner
    /// @param value The genome value to be added
    function addGenome(address owner, uint value) external {
        genomes[owner] = value;
        console.log('The value is %s',value);
    }

    /// @notice Retrieves the genome value of a given owner
    /// @param owner The address of the genome owner
    /// @return The genome value of the given owner
    function getGenome(address owner) external view returns (uint) {
        return genomes[owner];
    }

    /// @notice Encodes metadata properties into a single uint256 genome
    /// @param metadata The metadata struct containing NFT properties
    /// @return result The encoded genome as a uint256
    function encodeMetadata(
        Metadata calldata metadata
    ) external pure returns (uint256 result) {
        result = _encodeProperty(
            PropertyOrder.bgColor,
            metadata.bgColor,
            result
        );
        result = _encodeProperty(
            PropertyOrder.bgEffect,
            metadata.bgEffect,
            result
        );
        result = _encodeProperty(PropertyOrder.wings, metadata.wings, result);
        result = _encodeProperty(
            PropertyOrder.skinColor,
            metadata.skinColor,
            result
        );
        result = _encodeProperty(
            PropertyOrder.skinPattern,
            metadata.skinPattern,
            result
        );
        result = _encodeProperty(PropertyOrder.body, metadata.body, result);
        result = _encodeProperty(PropertyOrder.mouth, metadata.mouth, result);
        result = _encodeProperty(PropertyOrder.eyes, metadata.eyes, result);
        result = _encodeProperty(PropertyOrder.pet, metadata.pet, result);
        result = _encodeProperty(
            PropertyOrder.accessory,
            metadata.accessory,
            result
        );
        result = _encodeProperty(PropertyOrder.border, metadata.border, result);
    }

    /// @notice Decodes a genome into its constituent metadata properties
    /// @param genome The encoded genome as a uint256
    /// @return metadata The decoded metadata struct
    function decodeMetadata(
        uint256 genome
    ) public pure returns (Metadata memory metadata) {
        metadata.bgColor = _decodeProperty(PropertyOrder.bgColor, genome);
        metadata.bgEffect = _decodeProperty(PropertyOrder.bgEffect, genome);
        metadata.wings = _decodeProperty(PropertyOrder.wings, genome);
        metadata.skinColor = _decodeProperty(PropertyOrder.skinColor, genome);
        metadata.skinPattern = _decodeProperty(
            PropertyOrder.skinPattern,
            genome
        );
        metadata.body = _decodeProperty(PropertyOrder.body, genome);
        metadata.mouth = _decodeProperty(PropertyOrder.mouth, genome);
        metadata.eyes = _decodeProperty(PropertyOrder.eyes, genome);
        metadata.hat = _decodeProperty(PropertyOrder.hat, genome);
        metadata.pet = _decodeProperty(PropertyOrder.pet, genome);
        metadata.accessory = _decodeProperty(PropertyOrder.accessory, genome);
        metadata.border = _decodeProperty(PropertyOrder.border, genome);
    }

    /// @notice Decodes a single property from a genome
    /// @param property The property to decode
    /// @param genome The encoded genome
    /// @return The value of the decoded property
    function _decodeProperty(
        PropertyOrder property,
        uint genome
    ) private pure returns (uint256) {
        uint256 shiftBy = 8 * uint(property);
        return 255 & (genome >> shiftBy);
    }

    /// @notice Encodes a single property into a genome
    /// @param property The property to encode
    /// @param propertyValue The value of the property to encode
    /// @param genome The current genome to encode into
    /// @return The updated genome with the new property encoded
    function _encodeProperty(
        PropertyOrder property,
        uint propertyValue,
        uint genome
    ) private pure returns (uint256) {
        uint256 shiftBy = 8 * uint(property);
        return genome | (propertyValue << shiftBy);
    }
    
}
```