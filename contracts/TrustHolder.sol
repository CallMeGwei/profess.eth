pragma solidity 0.5.8;

import "./interfaces/TrustHolderI.sol";
import "./Ownable.sol";

contract TrustHolder is TrustHolderI, Ownable {

    struct Trust {
        uint8 value; // 0 means not recognized. 255 means same as self. 1 - 100 are for trust scale values. Other values mean full trust *plus.
        address delegatedTo; // if not the zero address, then trust will be delegated to this address if trust value is zero.
    }

    mapping(address => mapping(address => Trust)) internal _trustRecords;
    mapping(address => address) internal _defaultDelegations;

    uint public maxLookupDepth; // can be changed by owner.
    uint public minLookupDepth; // can never be reduced.

    constructor(uint initialMinLookupDepth, uint initialMaxLookupDepth) public {
        setMinLookupDepth(initialMinLookupDepth);
        setMaxLookupDepth(initialMaxLookupDepth);
    }

    function setMinLookupDepth(uint newMinLookupDepth)
    public
    onlyOwner {
        require(newMinLookupDepth > 0, "Min number of lookups must be greater than zero.");
        require(newMinLookupDepth >= minLookupDepth, "Min number of lookups can never be decreased.");
        emit LogMinLookupDepthSet(msg.sender, newMinLookupDepth);
        minLookupDepth = newMinLookupDepth;
    }

    function setMaxLookupDepth(uint newMaxLookupDepth)
    public
    onlyOwner {
        require(newMaxLookupDepth >= minLookupDepth, "Max number of lookup must at least be equal to the min number of lookups.");
        emit LogMaxLookupDepthSet(msg.sender, newMaxLookupDepth);
        maxLookupDepth = newMaxLookupDepth;
    }

    function setRecordTrustValue(address entityTrusted, uint8 trustValue)
    public {
        require(msg.sender != entityTrusted, "An address may not make public trust claims about itself.");
        emit LogRecordTrustValueSet(msg.sender, entityTrusted, trustValue);
        _trustRecords[msg.sender][entityTrusted].value = trustValue;
    }

    function setRecordTrustDelegation(address entityTrusted, address trustDelegatedTo)
    public {
        require(msg.sender != entityTrusted, "An address may not make public trust claims about itself.");
        require(msg.sender != trustDelegatedTo, "An address may not delegate trust to itself.");
        require(entityTrusted != trustDelegatedTo, "An address may not delegate trust about some address to the address itself.");
        emit LogRecordDelegateSet(msg.sender, entityTrusted, trustDelegatedTo);
        _trustRecords[msg.sender][entityTrusted].delegatedTo = trustDelegatedTo;
    }

    function setDefaultTrustDelegation(address defaultDelegate)
    public {
        require(defaultDelegate != msg.sender, "An address may not delegate trust to itself.");
        emit LogDefaultDelegateSet(msg.sender, defaultDelegate);
        _defaultDelegations[msg.sender] = defaultDelegate;
    }

    function getRawPublicTrustDetails(address entityTrusting, address entityTrusted)
    public view
    returns(uint8 trustValue, address recordSpecificDelegate, address defaultDelegate) {
        Trust memory trustRecord = _trustRecords[entityTrusting][entityTrusted];
        return (trustRecord.value, trustRecord.delegatedTo, _defaultDelegations[entityTrusting]);
    }

    function getPublicTrustValue(address entityTrusting, address entityTrusted, uint lookupLevel, uint maxLookupDepthOverride)
    public view
    returns(uint publicTrustValue, address trustSource, uint lookupDepth) {
        require(lookupLevel < maxLookupDepth, "Number of lookups exceeded global max.");
        require(lookupLevel < maxLookupDepthOverride, "Number of lookups exceeded specified max.");

        Trust memory trustRecord = _trustRecords[entityTrusting][entityTrusted];
        address defaultDelegator = _defaultDelegations[entityTrusting];

        if (trustRecord.value != 0) {
            return (trustRecord.value, entityTrusting, lookupLevel);
        } else if (trustRecord.delegatedTo != address(0)) {
            return getPublicTrustValue(trustRecord.delegatedTo, entityTrusted, lookupLevel + 1, maxLookupDepthOverride);
        } else if (defaultDelegator != address(0)) {
            return getPublicTrustValue(defaultDelegator, entityTrusted, lookupLevel + 1, maxLookupDepthOverride);
        } else {
            return (trustRecord.value, entityTrusting, lookupLevel);
        }
    }
}