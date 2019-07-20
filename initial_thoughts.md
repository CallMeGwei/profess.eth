# profess.eth - initial thoughts

## We Need to Democratize Credential Issuance

Work experience, standardized test scores, college transcripts, continuing education credits... these common credentials can influence business relationships and career opportunities. Of course, this is no secret - people are spending a significant, and ever-increasing, share of their resources to obtain such credentials for themselves and their families.

In an age of instant information, the cost of acquiring and testing skills should be plummeting. Indeed, this is very likely the case - however, skills are significantly less valuable without some kind of _credentials_. And the cost of credential issuance, clearly, is headed in the wrong direction.

Credentials, ostensibly, are the solution to a trust problem - people and organizations expect _proof_ of experience from individuals they intend to transact with. This certainly doesn't seem like an unreasonable expectation. The reality, however, is that the cost of certifiable education and experience is failing to fall proportionally with the cost of alternative education and the acquisition of skills. The expectation for the _"proper"_ credentials is an obstacle for many and increasing transaction costs unnecessarily for everyone. It's also causing myriad 'lesser' credentials to be overlooked or ignored - needlessly - rather than being integrated into and recognized as a more complete representation of a person's past experiences and skill sets.

If we want credential costs to fall so that more skilled people can compete and participate in the global economy, then we need to democratize the issuance of credentials. We need to build organic "webs of trust" in the credential space that can (at least) augment the current limited, slower-moving, large, for-profit, credentialing enterprises that are already ingrained in our societies.

### The Current System is _Functionally_ Antiquated

Even when the legacy credential system works - it is antiquated, slow, painfully inefficient, and ripe for error and abuse. Confirming credentials often involves phone calls, postage, paper and time. All of these things introduce friction - and few are cryptographically secure. In other words: despite all of the inefficient ceremony involved, the result is much less trustworthy than we tend to give it credit for. The citizens of the world need a global, **public** credential registry.

### The Way Forward

Making it easy for any individual and/or any organization to issue a credential on a public blockchain will realize meaningful, non-trivial benefits. These are benefits that will be shared by legacy credentialing institutions, emerging education platforms, heretofore overlooked venues for skill acquisition, and all other participants seeking to transact in the global economy.

Perhaps the most obvious advantage is the ability to instantly verify credential issuance in a secure, consistent, and accessible manner with no down time, external costs, or third-party permissions required... no stamps, no paper, no "business" hours to contend with.

For those seeking talent, having access to a global data stream of credential issuance/acceptance could be extremely valuable. For those looking for employment or obtaining education - knowing their skills are broadcast, verified, and immutable on a public blockchain should yield more opportunities and would grant credential recipients additional piece of mind.

### The Trust Problem

The most glaring problem with an open credential registry is that without some idea of "authority" or "reputation", trusting credentials on such a system might seem risky. In fact, it is already difficult for individuals or single organizations to decide which credentialing institutions to trust - this is why such a relatively small number of credentials are often accepted to begin with. By providing more transparent information, on a global scale, publicly available to participants everywhere - everyone involved will have more information. This should make decisions _less_ difficult and reasoning about trust _easier_.

We can use webs of trust and the wisdom of the crowd to make more intelligent decisions when evaluating credential **issuers** in a way that should level the playing field and increase the quality of issued credentials overall.

Furthermore, an entire ecosystem could develop around the public credential information that could lead to many different perspectives and methodologies for evaluating the raw data. In all of these interpretation, curation, and presentation activities, anyone could participate.

## Considerations

### The Backhanded "Credential"

Opening a credential registry up to anyone is bound to result in some less-than-desirable behavior. Consider the issuance of a "credential" that's demeaning, underhanded, or slanderous issued by a hostile actor. To neutralize the effects of such behavior, the registry should not necessarily emit events on credential _issuance_. Rather, credentials should be "claimed"/"recognized"/"acknowledged" by the credential recipients. Accepting a credential would emit an event (by default).

There could be some small cost associated with credential issuance. That cost could be refundable if the credential is 'claimed' (or the credential could, possibly, be burned before being claimed for a partial refund - in case of issuance errors, for instance).

### Ethereum Addresses Not Required For MVP

It is unrealistic at this point to expect every individual to claim their credentials on chain. Wallets are still not quite mainstream and most users are still more comfortable with web2.

Sending some small amount of ether to a specific credential record could enable credential pinning. This would act in some ways like a 'claim' but would only guarantee immutability of the record (and refund the issuer if applicable).

Any number of services could pin a credential until it was claimed. After being claimed, all pins would be refunded and the credential would no longer be pin-able.

This mechanism is to allow web2 users to benefit from blockchain credentials via third parties of their choice until they are ready to manage their credentials themselves.

### Some Level of Privacy

Not everyone would be comfortable with the idea of their credential information being publicly visible on a blockchain. Of course this could be opt-in at the issuer level, but having some mechanism to preserve privacy by default may make sense here.

At the time a credential is pinned or claimed, it would be converted into a clear-text copy of the credential. In the interim it could be protected by some secret, (which would need to be derived, in part, at least, from credential specific information) to prevent fraudulent claims.

### The Abilities of Claimants

After someone has claimed a credential, they should have greater control over that record. Perhaps they could add a name to the record (for marriage or a name change), request the record be burned by issuer, request the credential be extended by the issuer [in case of some credential that must be renewed], or add some brief notes to the credential. Credential owners should not have the ability to independently delete a credential, but they should be able to prioritize them, flag them as archived, irrelevant, invalid or expired.

### The Abilities of Issuers

Issuers should be able to issue credentials and delete unclaimed credentials (perhaps after some short time lock). They should also be able to burn a credential if the credential owner has requested such. An owner may wish to burn an old credential when requesting an amended replacement, for instance. Or if they discovered a credential was somehow being misused or misrepresented.

### The Abilities of Others

Any address should be able to attach a public level of trust to a specific credential, a credential issuer, or a credential signer. This will allow users and front ends to assemble and parse a web of trust as they relate to on-chain credentials specifically.

### Credential Signing At Issuance

Credentials should be able to be endorsed by other issuers/individuals. Slots for endorsement should be specified at credential creation time and endorsers must be specified Ethereum addresses. This would allow affiliated, parent, and/or regulatory organizations/individuals to signal trust in/support for a credential at time of issuance.

### Credential Signing After Issuance

Credentials should be able to be endorsed by other issuers/individuals even after issuance. This may help with internal and/or international credential evaluations. There should be a cost for signing an already issued credential and these signatures would need to be accepted by the credential owners before the signing fees could be refunded.

## Possible Use Cases / Benefits

* A university could issue a credential for each credit completed.
  * A student could request a degree via smart contract when they had all of the required credits recorded on-chain. Or the university could issue degrees automatically.
  * If a student had to transfer between institutions, there would be no lag time for the new institution to receive the old institutions credentials.
* The value of an experience or qualification wouldn't be necessarily derived solely from a particular institutional issuer. Individual instructors could sign off on credentials, and this may ultimately allow them more flexibility when it comes to monetizing their teaching. It may also allow students to focus more on the reputations of instructors rather than just institutions.
* A corporation could issue raises or bonuses tied to credentials being obtained.
* A professional license credential could be contingent on holding certain current continuing education credentials.
* Your neighbor, who happens to be a famous chess player, could give you a credential saying you're a good chess player. People that know about chess would probably respect that credential.
* If you mowed lawns in Ohio, you could have your customers leave you some credentials saying you're a first-class landscaper. If you moved to Michigan, you could present your credentials to new clients. They might not trust that all of your former clients are real or honest, but they could inspect those reviewers and make a trust determination based on their credentials.

## Notes

* Credentials are pretty flexible. They can be issued for qualitative or quantitative qualities of an individual or their experience.
* Credentials in aggregate are not the same as **reviews** in aggregate. Reviews may include negative wording or describe sub-par experiences or interactions with an individual. Since credentials must be *accepted* by the individual, they will very-likely be biased in the favor of the individual who accepted them.
* After accepting some number of credentials - depending on how much others trusted the credential issuers - the credentials may start to comprise something like a decentralized identity for an individual. This is worth noting, but the project's initial sole focus is mainstreaming and simplifying credential issuance and exchange on-chain.
