pragma solidity 0.5.8;

contract EntityHolderI {

    event EntityRegistered(address entityAddress, uint registrationTimestamp);
    event EntityTransferInitiated(address whoInitiated, address transferTo);
    event EntityTransferFinalized(address whoCompletedTransfer, address oldEntityAddress);

    event EntityPreferedNameSet(address entityAddress, string nameSetAsPrefered);
    event EntityNameAdded(address entityAddress, string nameAdded);
    event EntityNoteSet(address entityAddress, string noteSeTo);
    event EntityImageUrlSet(address entityAddress, string imageUrlSetTo);
    event EntityExtraSet(address entityAddress, string noteSeTo);

}