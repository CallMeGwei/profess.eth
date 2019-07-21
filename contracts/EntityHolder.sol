pragma solidity 0.5.8;

import "./interfaces/EntityHolderI.sol";

contract EntityHolder is EntityHolderI {

    /**
    * @notice Structure for representing an entity in the credential / trust ecosystem.
    * @param registeredTimestamp Set at initial registration and immutable.
    * @param dateRecognized Set at initial registration and immutable. Can be date of birth for singletons or date of incorporation/organization for establishments.
    * @param preferredName Can be set to any registered name at any time by entity controller.
    * @param registeredNames Append-only list of registered names for entity. Appendable by entity controller at any time.
    * @param note Public note. Editable by entity controller at any time.
    * @param imageUrl Public image. Editable by entity controller at any time.
    * @param extra JSON formatted values that can be consumed by applications. Editable by entity controller at any time.
    * @param assumedEntities A list of addresses that were transfered to this entity.
    * @param transferedToAddress Can be set by entity controller to signal decommissioning of an address (and transfer of entity to new address). Once set, immutable.
    * @param transferTimestamp Set at time of transfer out. Immutable.
    */
    struct Entity {
        uint registeredTimestamp;
        uint dateRecognized;
        string preferredName;
        string[] registeredNameList;
        mapping(bytes32 => bool) registeredNameMap;
        string note;
        string imageUrl;
        string extra;

        address[] assumedEntities;
        address transferedToAddress;
        uint transferTimestamp;
    }

    mapping(address => Entity) public entities;

    function registerNewEntity(string memory name, uint dateRecognized, string memory note, string memory imageUrl, string memory extra)
    public {
        require(bytes(name).length != 0, "Name is required.");
        require(dateRecognized != 0, "Date recognized is required.");

        require(!isEntityRegistered(msg.sender), "Address is already registered as an entity.");

        emit EntityRegistered(msg.sender, block.timestamp);

        Entity storage newEntity = entities[msg.sender];

        newEntity.registeredTimestamp = block.timestamp;
        addName(name);
        setPreferredName(name);
        newEntity.dateRecognized = dateRecognized;
        newEntity.note = note;
        newEntity.imageUrl = imageUrl;
        newEntity.extra = extra;
    }

    function transferInitiate(address toAddress)
    public
    requireRegistered(msg.sender){
        require(msg.sender != toAddress, "Entity may not be transfered to self.");
        Entity storage oldEntity = entities[msg.sender];
        require(oldEntity.transferTimestamp == 0, "Entity has already been completely transfered.");

        emit EntityTransferInitiated(msg.sender, toAddress);

        oldEntity.transferedToAddress = toAddress;
    }

    function transferFinalize(address entityOldAddress)
    public {
        require(isEntityRegistered(entityOldAddress), "Entity to be transfered from must be a registered entity.");
        require(isEntityRegistered(msg.sender), "Entity to be transfered to must be a registered entity.");
        Entity storage oldEntity = entities[entityOldAddress];
        Entity storage newEntity = entities[msg.sender];

        require(oldEntity.transferedToAddress == msg.sender, "Transfers require the permission of the entity being transfered.");

        emit EntityTransferFinalized(msg.sender, entityOldAddress);

        oldEntity.transferTimestamp = block.timestamp;
        newEntity.registeredTimestamp = block.timestamp;

        newEntity.assumedEntities.push(entityOldAddress);
    }

    function isEntityRegistered(address entityAddress)
    public view
    returns(bool entityRegistered) {
        return entities[entityAddress].registeredTimestamp != 0;
    }

    modifier requireNotTransfered(address entityAddress){
        require(entities[entityAddress].transferedToAddress == address(0),
            "This entity has been marked as transfered. No further modifications are possible.");
        _;
    }

    modifier requireRegistered(address entityAddress){
        require(isEntityRegistered(entityAddress), "Address is not a registered entity.");
        _;
    }

    function addName(string memory name)
    public
    requireRegistered(msg.sender)
    requireNotTransfered(msg.sender){
        require(!isRegisteredName(msg.sender, name), "Name is already registered for entity.");

        emit EntityNameAdded(msg.sender, name);

        entities[msg.sender].registeredNameList.push(name);
        entities[msg.sender].registeredNameMap[keccak256(abi.encodePacked(name))] = true;
    }

    function setPreferredName(string memory name)
    public
    requireRegistered(msg.sender)
    requireNotTransfered(msg.sender){
        require(isRegisteredName(msg.sender, name), "Name must be registered before it can be set as the preferred name.");

        emit EntityPreferedNameSet(msg.sender, name);

        entities[msg.sender].preferredName = name;
    }

    function setNote(string memory newNote)
    public
    requireRegistered(msg.sender){

        emit EntityNoteSet(msg.sender, newNote);

        entities[msg.sender].note = newNote;
    }

    function setImageUrl(string memory newImageUrl)
    public
    requireRegistered(msg.sender){

        emit EntityImageUrlSet(msg.sender, newImageUrl);

        entities[msg.sender].imageUrl = newImageUrl;
    }

    function setExtra(string memory newExtra)
    public
    requireRegistered(msg.sender){

        emit EntityExtraSet(msg.sender, newExtra);

        entities[msg.sender].extra = newExtra;
    }

    function isRegisteredName(address entityAddress, string memory name)
    public view
    requireRegistered(entityAddress)
    returns(bool nameIsRegistered){
        return(entities[entityAddress].registeredNameMap[keccak256(abi.encodePacked(name))]);
    }

    function getEntityPreferredName(address entityAddress)
    public view
    requireRegistered(entityAddress)
    returns(string memory preferredName) {
        return entities[entityAddress].preferredName;
    }

    function getNumberRegisteredNames(address entityAddress)
    public view
    requireRegistered(entityAddress)
    returns(uint numberOfNamesOnRecord) {
        return entities[entityAddress].registeredNameList.length;
    }

    function getSpecificRegisteredName(address entityAddress, uint registeredNameIndex)
    public view
    requireRegistered(entityAddress)
    returns(string memory registeredName) {
        require(registeredNameIndex < getNumberRegisteredNames(entityAddress), "Registered name index is out of bounds.");
        return entities[entityAddress].registeredNameList[registeredNameIndex];
    }
}