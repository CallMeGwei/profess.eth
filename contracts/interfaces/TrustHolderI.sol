pragma solidity 0.5.8;

contract TrustHolderI {

    /**
    * @notice Event emitted when minLookupDepth is set.
    * @param whoSet The address that set the new value.
    * @param newMinLookupDepth The new uint value for mixLookupDepth.
    */
    event LogMinLookupDepthSet(address whoSet, uint newMinLookupDepth);

    /**
    * @notice Event emitted when maxLookupDepth is set.
    * @param whoSet The address that set the new value.
    * @param newMaxLookupDepth The new uint value for maxLookupDepth.
    */
    event LogMaxLookupDepthSet(address whoSet, uint newMaxLookupDepth);

    /**
    * @notice Event emitted when an address sets a default delegate for its trust.
    * @param trustingEntity The address that set a delegate for itself.
    * @param trustDelegatedTo The address that trust is delegated to.
    */
    event LogDefaultDelegateSet(address trustingEntity, address trustDelegatedTo);

    /**
    * @notice Event emitted when an address sets a default delegate for a specific trust record.
    * @param trustingEntity The address that set a delegate for one of its records.
    * @param trustedEntity The address about which trust requests will be delegated for.
    * @param trustDelegatedTo The address that trust is delegated to.
    */
    event LogRecordDelegateSet(address trustingEntity, address trustedEntity, address trustDelegatedTo);

    /**
    * @notice Event emitted when an address explicitly sets a trust value for an entity.
    * @param trustingEntity The address that is explicitly setting a trust value.
    * @param trustedEntity The address about which the trust value is being recorded.
    * @param trustValueSet The value set in the trust record.
    */
    event LogRecordTrustValueSet(address trustingEntity, address trustedEntity, uint8 trustValueSet);

    /**
    * @notice Used by contract owner to increase the (guaranteed) minimum number of lookups for finding a trust value.
    * @param newMinLookupDepth The new number of minimum lookups guaranteed.
    */
    function setMinLookupDepth(uint newMinLookupDepth) public;

    /**
    * @notice Used by contract owner to modify the maximum number of lookups for finding a trust value.
    * @dev newMaxLookupDepth can never be less than minLookupDepth.
    * @param newMaxLookupDepth The new number of maximum lookups permitted.
    */
    function setMaxLookupDepth(uint newMaxLookupDepth) public;

    /**
    * @notice Allows an address to record their trust level for another entity.
    * @param entityTrusted The address about which the trust value is being set.
    * @param trustValue The numeric trust value being recorded.
    */
    function setRecordTrustValue(address entityTrusted, uint8 trustValue) public;

    /**
    * @notice Allows an address to delegate their trust values for a specific record to another address.
    * @param entityTrusted The address about which the trust value is being delegated.
    * @param trustDelegatedTo The address that trust is delegated to.
    */
    function setRecordTrustDelegation(address entityTrusted, address trustDelegatedTo) public;

    /**
    * @notice Allows an address to delegate their default trust values for any records they have not explicitly set.
    * @param defaultDelegate The address that trust is delegated to by default.
    */
    function setDefaultTrustDelegation(address defaultDelegate) public;

    /**
    * @notice Returns the raw trust record from entityTrusting for entityTrusted.
    * @param entityTrusting The maintainer of the trust record.
    * @param entityTrusted The entity for which the trust record is about.
    * @return trustValue The trust value exactly as it appears in the trust record.
    * @return recordSpecificDelegate The record-specific delegate address.
    * @return defaultDelegate The default delegate address for the record.
    */
    function getRawPublicTrustDetails(address entityTrusting, address entityTrusted)
    public view
    returns(uint8 trustValue, address recordSpecificDelegate, address defaultDelegate);

    /**
    * @notice Returns the effective values for a trust record query.
    * @param entityTrusting The maintainer of the trust record.
    * @param entityTrusted The entity for which the trust record is about.
    * @param lookupLevel The starting lookup level depth of the request.
    * @param maxLookupsOverride Value used to set an upper bound on the number of lookups for a request.
    * @return publicTrustValue The trust value returned by lookup.
    * @return trustSource The actual address that explicitly set the trust value. (That resolved the request.)
    * @return lookupDepth At what depth the trust record request was resolved.
    */
    function getPublicTrustValue(address entityTrusting, address entityTrusted, uint lookupLevel, uint maxLookupsOverride)
    public view
    returns(uint publicTrustValue, address trustSource, uint lookupDepth);
}