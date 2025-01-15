pragma solidity ^0.8.13;
import "hardhat/console.sol";

contract NFTGenome {
    mapping(address => uint) private genomes;

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

    function addGenome(address owner, uint value) external {
        genomes[owner] = value;
        console.log('The value is %s',value);
    }

    function getGenome(address owner) external view returns (uint) {
        return genomes[owner];
    }

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

    function _decodeProperty(
        PropertyOrder property,
        uint genome
    ) private pure returns (uint256) {
        uint256 shiftBy = 8 * uint(property);
        return 255 & (genome >> shiftBy);
    }

    function _encodeProperty(
        PropertyOrder property,
        uint propertyValue,
        uint genome
    ) private pure returns (uint256) {
        uint256 shiftBy = 8 * uint(property);
        return genome | (propertyValue << shiftBy);
    }
    
}
