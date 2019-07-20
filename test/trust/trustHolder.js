const TrustHolder = artifacts.require("TrustHolder");

const truffleAssert = require('truffle-assertions');
const { toWei,fromWei, padLeft, toBN } = web3.utils;

contract("TrustHolder", function(accounts){

    let owner, user1, user2, user3, addressToBeTrusted, addressToDelegate1, addressToDelegate2, entityAnybody;
    const addressZero = padLeft(0, 40);

    before("should prepare", async () => {
        assert.isAtLeast(accounts.length, 9);
        [ owner, user1, user2, user3, addressToBeTrusted, addressToDelegate1, addressToDelegate2, entityAnybody ] = accounts;
    });

    describe("deployment", function() {

        let minLookups, maxLookups;

        it("should not be possible to deploy a TrustHolder where minLookups is greater than maxLookups", async function() {

            minLookups = 1;
            maxLookups = minLookups - 1;
            await truffleAssert.reverts(
                TrustHolder.new(minLookups, maxLookups, {from: owner})
            );
        });

        it("should be possible to deploy a TrustHolder where minLookups is less than maxLookups", async function() {

            minLookups = 1;
            maxLookups = minLookups + 1;
            await TrustHolder.new(minLookups, maxLookups, {from: owner});
        });

        it("should be possible to deploy a TrustHolder where minLookups is equal to maxLookups", async function() {

            minLookups = 1;
            maxLookups = minLookups;
            await TrustHolder.new(minLookups, maxLookups, {from: owner});
        });

        it("should not be possible to deploy a TrustHolder where minLookups is zero", async function() {

            minLookups = 0;
            maxLookups = minLookups;
            await truffleAssert.reverts(
                TrustHolder.new(minLookups, maxLookups, {from: owner, value: 10})
            );
        });

        it("should not be possible to deploy a TrustHolder if value is sent", async function() {

            minLookups = 1;
            maxLookups = minLookups;
            await truffleAssert.reverts(
                TrustHolder.new(1, 1, {from: owner, value: 10})
            );
        });

    });

    describe("contract functionality", async () => {

        let aTrustHolder, minLookups, maxLookups;

        beforeEach("should deploy a standard TrustHolder where minLookups is less than maxLookups", async () =>{

            minLookups = 1;
            maxLookups = minLookups + 2;

            aTrustHolder = await TrustHolder.new(minLookups, maxLookups, {from: owner});

        });

        describe("contract owner abilities", async () => {

            describe("ownership adjustments", async () => {

                it("should not be possible for anyone aside from owner to renounceOwnership", async () => {
        
                    await truffleAssert.reverts(
                        aTrustHolder.renounceOwnership({ from: entityAnybody })
                    );
        
                });
        
                it("should not be possible for anyone aside from owner to transferOwnership", async () => {
        
                    await truffleAssert.reverts(
                        aTrustHolder.transferOwnership(user1, { from: entityAnybody })
                    );
        
                });
        
        
                it("should be possible for owner to transferOwnership", async () => {

                    await aTrustHolder.transferOwnership(user1, { from: owner });
                    let newOwner = await aTrustHolder.owner();

                    assert.equal(newOwner, user1);

                });
        
        
                it("should be possible for owner to renounceOwnership", async () => {

                    await aTrustHolder.renounceOwnership({ from: owner });
                    let newOwner = await aTrustHolder.owner();

                    assert.equal(newOwner, addressZero);

                });
                
            });

            describe("lookup adjustments", async () => {

                it("should not be possible for owner to adjust minLookups down", async () => {

                    let currentNumMinLookups = await aTrustHolder.minLookups();

                    await truffleAssert.reverts(
                        aTrustHolder.setMinNumLookups(currentNumMinLookups.sub(toBN(1)), { from: owner })
                    );

                });

                it("should be possible for owner to adjust minLookups up", async () => {

                    let currentNumMinLookups = await aTrustHolder.minLookups();

                    await aTrustHolder.setMinNumLookups(currentNumMinLookups.add(toBN(1)), { from: owner });

                });

                it("should be possible for owner to adjust maxLookups down", async () => {

                    let currentNumMaxLookups = await aTrustHolder.maxLookups();

                    await aTrustHolder.setMaxNumLookups(currentNumMaxLookups.sub(toBN(1)), { from: owner });

                });

                it("should be possible for owner to adjust maxLookups up", async () => {

                    let currentNumMaxLookups = await aTrustHolder.maxLookups();

                    await aTrustHolder.setMaxNumLookups(currentNumMaxLookups.add(toBN(1)), { from: owner });

                });

                it("should not be possible for owner to adjust maxLookups down to less than minLookups", async () => {

                    let currentNumMaxLookups = await aTrustHolder.maxLookups();

                    await truffleAssert.reverts(
                        aTrustHolder.setMinNumLookups(currentNumMaxLookups.sub(currentNumMaxLookups), { from: owner })
                    );

                });

                it("should not be possible for anyone aside from owner to adjust maxLookups or minLookups", async () => {

                    let currentNumMinLookups = await aTrustHolder.minLookups();
                    let currentNumMaxLookups = await aTrustHolder.maxLookups();

                    await truffleAssert.reverts(
                        aTrustHolder.setMaxNumLookups(currentNumMaxLookups.add(toBN(1)), { from: entityAnybody })
                    );

                    await truffleAssert.reverts(
                        aTrustHolder.setMaxNumLookups(currentNumMaxLookups.sub(toBN(1)), { from: entityAnybody })
                    );

                    await truffleAssert.reverts(
                        aTrustHolder.setMaxNumLookups(currentNumMinLookups.add(toBN(1)), { from: entityAnybody })
                    );

                });

            });

        });

        describe("contract user abilities", async () => {

            const unknownTrust = 0;
            const minTrust = 1;
            const someTrust = 50;
            const maxTrust = 100;
            const sameAsSelf = 255;
            
            const initialLookupNum = 0;
            let maxLookupNumOverride = 6;
            let smallMaxLookupsOverride = 2;
    
            describe("user trust values", async () => {
    
                it("should always default to an an unknown trust level for an entity", async () => {
            
                    let trustValue = await aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 });
                    assert.equal(trustValue[0], unknownTrust);
    
            });
    
                it("should be possible for a user to set their trust level for an address directly", async () => {
            
                        await aTrustHolder.setRecordTrustValue(addressToBeTrusted, someTrust, { from: user1 });
                        let newTrustValue = await aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 });
                        assert.equal(newTrustValue[0], someTrust);
        
                });
    
            });

            describe("user trust delegations", async () => {

                describe("record level trust delegations", async () => {

                    it("should be possible for a user to set a delegate for trust at the record level", async () => {
            
                        await aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user2, { from: user1 });
                        let newTrustValue = await aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 });
                        assert.equal(newTrustValue[1], user2);
        
                    });

                    it("should not be possible for a user to set itself as a delegate for trust at the record level", async () => {
            
                        await truffleAssert.reverts(
                            aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user1, { from: user1 })
                        );
        
                    });

                    it("should retrieve the correct trust level from a record with a single level of delegation at the record level", async () => {

                        let expectedLookupLevel = 1;
                        await aTrustHolder.setRecordTrustValue(addressToBeTrusted, someTrust, { from: user2 });
            
                        await aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user2, { from: user1 });
                        let newTrustValue = await aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 });

                        assert.equal(newTrustValue[0], someTrust);
                        assert.equal(newTrustValue[1], user2);
                        assert.equal(newTrustValue[2], expectedLookupLevel);
        
                    });

                    it("should retrieve the correct trust level from a record with two levels of delegation at the record level", async () => {

                        let expectedLookupLevel = 2;
                        await aTrustHolder.setRecordTrustValue(addressToBeTrusted, minTrust, { from: user3 });

                        await aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user3, { from: user2 });
                        await aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user2, { from: user1 });
                        let newTrustValue = await aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 });

                        assert.equal(newTrustValue[0], minTrust);
                        assert.equal(newTrustValue[1], user3);
                        assert.equal(newTrustValue[2], expectedLookupLevel);
        
                    });

                    it("should fail to retrieve a trust level from a record with more levels of delegation at the record level than maxLookupsOverride", async () => {

                        await aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user3, { from: user2 });
                        await aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user2, { from: user1 });

                        await truffleAssert.reverts(
                            aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, smallMaxLookupsOverride, { from: user1 })
                        );
        
                    });

                    it("should fail to retrieve a trust level from a record with more levels of delegation at the record level than maxLookups", async () => {

                        minLookups = 1;
                        maxLookups = 2;

                        aTrustHolder = await TrustHolder.new(minLookups, maxLookups, {from: owner});

                        await aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user3, { from: user2 });
                        await aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user2, { from: user1 });

                        await truffleAssert.reverts(
                            aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 })
                        );
        
                    });
                });

                describe("default level trust delegations", async () => {

                    it("should be possible for a user to set a default delegate for trust", async () => {
            
                        await aTrustHolder.setDefaultTrustDelegation(user2, { from: user1 });
                        let newTrustValue = await aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 });
                        assert.equal(newTrustValue[1], user2);
        
                    });

                    it("should not be possible for a user to set themselves as a default delegate", async () => {
            
                        await truffleAssert.reverts(
                            aTrustHolder.setDefaultTrustDelegation(user1, { from: user1 })
                        );
        
                    });

                    it("should retrieve the correct trust level from a record with a single default level delegation", async () => {

                        let expectedLookupLevel = 1;
                        await aTrustHolder.setRecordTrustValue(addressToBeTrusted, someTrust, { from: user2 });
            
                        await aTrustHolder.setDefaultTrustDelegation(user2, { from: user1 });
                        let newTrustValue = await aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 });

                        assert.equal(newTrustValue[0], someTrust);
                        assert.equal(newTrustValue[1], user2);
                        assert.equal(newTrustValue[2], expectedLookupLevel);
        
                    });

                    it("should retrieve the correct trust level from a record with two levels of default delegation", async () => {

                        let expectedLookupLevel = 2;
                        await aTrustHolder.setRecordTrustValue(addressToBeTrusted, minTrust, { from: user3 });

                        await aTrustHolder.setDefaultTrustDelegation(user3, { from: user2 });
                        await aTrustHolder.setDefaultTrustDelegation(user2, { from: user1 });
                        let newTrustValue = await aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 });

                        assert.equal(newTrustValue[0], minTrust);
                        assert.equal(newTrustValue[1], user3);
                        assert.equal(newTrustValue[2], expectedLookupLevel);
        
                    });

                });

                describe("trust values, delegations, and precedence", async () => {

                    it("should return explicitly set values regardless of delegations", async () => {

                        let expectedLookupLevel = 0;

                        await aTrustHolder.setRecordTrustValue(addressToBeTrusted, minTrust, { from: user1 });
                        await aTrustHolder.setRecordTrustValue(addressToBeTrusted, someTrust, { from: user2 });
                        await aTrustHolder.setRecordTrustValue(addressToBeTrusted, maxTrust, { from: user3 });

                        await aTrustHolder.setDefaultTrustDelegation(user3, { from: user1 });
                        await aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user2, { from: user1 });

                        let newTrustValue = await aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 });

                        assert.equal(newTrustValue[0], minTrust);
                        assert.equal(newTrustValue[1], user1);
                        assert.equal(newTrustValue[2], expectedLookupLevel);

                    });

                    it("should return record level delegated values regardless of default delegation", async () => {

                        let expectedLookupLevel = 1;

                        await aTrustHolder.setRecordTrustValue(addressToBeTrusted, someTrust, { from: user2 });
                        await aTrustHolder.setRecordTrustValue(addressToBeTrusted, maxTrust, { from: user3 });

                        await aTrustHolder.setDefaultTrustDelegation(user3, { from: user1 });
                        await aTrustHolder.setRecordTrustDelegation(addressToBeTrusted, user2, { from: user1 });

                        let newTrustValue = await aTrustHolder.getPublicTrustValue(user1, addressToBeTrusted, initialLookupNum, maxLookupNumOverride, { from: user1 });

                        assert.equal(newTrustValue[0], someTrust);
                        assert.equal(newTrustValue[1], user2);
                        assert.equal(newTrustValue[2], expectedLookupLevel);

                    });

                });


            });
    
    
        });

    });

});