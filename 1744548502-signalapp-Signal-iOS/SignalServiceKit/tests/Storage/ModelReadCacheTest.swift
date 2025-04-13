//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import LibSignalClient
import XCTest

@testable import SignalServiceKit

private class FakeAdapter: ModelCacheAdapter<OWSUserProfile.Address, OWSUserProfile> {
    typealias KeyType = OWSUserProfile.Address
    typealias ValueType = OWSUserProfile

    var storage = [KeyType: ValueType]()
    override func read(key: KeyType, transaction: DBReadTransaction) -> ValueType? {
        return storage[key]
    }

    override func key(forValue value: ValueType) -> KeyType {
        return value.internalAddress
    }

    override func cacheKey(forKey key: KeyType) -> ModelCacheKey<KeyType> {
        return ModelCacheKey(key: key)
    }

    override func copy(value: ValueType) throws -> ValueType {
        return value
    }
}

class ModelReadCacheTest: SSKBaseTest {
    private lazy var adapter = { FakeAdapter(cacheName: "fake", cacheCountLimit: 1024, cacheCountLimitNSE: 1024) }()

    override func setUp() {
        super.setUp()
        // Create local account.
        SSKEnvironment.shared.databaseStorageRef.write { tx in
            (DependenciesBridge.shared.registrationStateChangeManager as! RegistrationStateChangeManagerImpl).registerForTests(
                localIdentifiers: .forUnitTests,
                tx: tx
            )
        }
    }

    // MARK: - Test ModelReadCache.readValues(for:, transaction:)

    func testReadNonNilCacheableValues() {
        let addresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        for address in addresses {
            adapter.storage[address] = OWSUserProfile(address: address)
        }
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                let keys = addresses.map { adapter.cacheKey(forKey: $0) }
                let actual = cache.readValues(for: AnySequence(keys), transaction: transaction)
                let expected = addresses.map { adapter.storage[$0]! }
                XCTAssertEqual(actual, expected)
            }
        }
    }

    func testReadNilCacheableValues() {
        let addresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                // Place values in the cache but not in storage.
                for address in addresses {
                    cache.writeToCache(
                        cacheKey: adapter.cacheKey(forKey: address),
                        value: OWSUserProfile(address: address)
                    )
                }
                let keys = addresses.map { adapter.cacheKey(forKey: $0) }
                // This should have a side-effect of removing values from the cache.
                let actual = cache.readValues(for: AnySequence(keys), transaction: transaction)
                let expected: [OWSUserProfile?] = [nil, nil]
                XCTAssertEqual(actual, expected)

                for address in addresses {
                    if let box = cache.readFromCache(cacheKey: adapter.cacheKey(forKey: address)) {
                        XCTAssertNil(box.value)
                    } else {
                        XCTFail("No cache entry for \(address)")
                    }
                }
            }
        }
    }

    func testReadNilUncacheableValues() {
        let addresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                // Place values in the cache but not in storage just to check that they don't get removed.
                for address in addresses {
                    let cacheKey = adapter.cacheKey(forKey: address)
                    cache.writeToCache(
                        cacheKey: cacheKey,
                        value: OWSUserProfile(address: address)
                    )
                    // Exclude it so that it won't be removed later.
                    cache.addExclusion(for: cacheKey)
                }
                let keys = addresses.map { adapter.cacheKey(forKey: $0) }

                // This should not have a side-effect of changing the cache beacuse the addresses were excluded.
                let actual = cache.readValues(for: AnySequence(keys), transaction: transaction)
                let expected: [OWSUserProfile?] = [nil, nil]
                XCTAssertEqual(actual, expected)

                for address in addresses {
                    if let box = cache.readFromCache(cacheKey: adapter.cacheKey(forKey: address)) {
                        // Good! Value is still there even though we didn't read it from db.
                        XCTAssertNotNil(box.value)
                    } else {
                        XCTFail("No cache entry for \(address)")
                    }
                }
            }
        }
    }

    func testReadMixOfNilAndNonNilCacheableValues() {
        // Before: Alice in DB but not cache. Bob in cache but not DB.
        // Assert: We can retrieve only Alice (because readValue(for:,transaction:) does not read from the cache so it won't see Bob).
        // After: Cache is empty.

        // 1. Put alice in DB.
        let alice: OWSUserProfile.Address = .otherUser(SignalServiceAddress.randomForTesting())
        let bob: OWSUserProfile.Address = .otherUser(SignalServiceAddress.randomForTesting())
        adapter.storage[alice] = OWSUserProfile(address: alice)
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                // 2. Put bob in cache.
                cache.writeToCache(
                    cacheKey: adapter.cacheKey(forKey: bob),
                    value: OWSUserProfile(address: bob)
                )

                // 3. Try to read alice and bob
                let keys = [alice, bob].map { adapter.cacheKey(forKey: $0) }
                // This should have a side-effect of removing values from the cache.
                let actual = cache.readValues(for: AnySequence(keys), transaction: transaction)
                let expected: [OWSUserProfile?] = [adapter.storage[alice]!, nil]
                XCTAssertEqual(actual, expected)

                // 4. Assert the cache is empty.
                XCTAssertNil(cache.readFromCache(cacheKey: adapter.cacheKey(forKey: alice)))
                // Bob has a box because it was removed from cache.
                XCTAssertNil(cache.readFromCache(cacheKey: adapter.cacheKey(forKey: bob))!.value)
            }
        }
    }

    // MARK: - Test ModelReadCache.getValue(for:, transaction:)

    func testGetUncachedSingleValueThatExists() {
        let addresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        for address in addresses {
            adapter.storage[address] = OWSUserProfile(address: address)
        }
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                let alice = addresses[0]
                let key = adapter.cacheKey(forKey: alice)
                let actual = cache.getValue(for: key, transaction: transaction)
                let expected = adapter.storage[alice]
                XCTAssertEqual(actual, expected)
            }
        }
    }

    func testGetSingleValueThatDoesNotExist() {
        let addresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        for address in addresses {
            adapter.storage[address] = OWSUserProfile(address: address)
        }
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                let alice: OWSUserProfile.Address = .otherUser(SignalServiceAddress.randomForTesting())
                let key = adapter.cacheKey(forKey: alice)
                let actual = cache.getValue(for: key, transaction: transaction)
                XCTAssertNil(actual)
            }
        }
    }

    func testGetCachedSingleValue() {
        let addresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        for address in addresses {
            adapter.storage[address] = OWSUserProfile(address: address)
        }
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                let alice = addresses[0]
                let key = adapter.cacheKey(forKey: alice)
                cache.writeToCache(cacheKey: key, value: adapter.storage[alice]!)
                // Remove Alice from DB to test that it comes from cache.
                adapter.storage.removeValue(forKey: alice)
                let actual = cache.getValue(for: key, transaction: transaction)
                let expected = OWSUserProfile(address: alice)
                XCTAssertEqual(actual?.serviceIdString, expected.serviceIdString)
            }
        }
    }

    func testGetSingleValueReturnNilOnCacheMiss() {
        let addresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        for address in addresses {
            adapter.storage[address] = OWSUserProfile(address: address)
        }
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                let alice = addresses[0]
                let key = adapter.cacheKey(forKey: alice)
                let actual = cache.getValue(for: key, transaction: transaction, returnNilOnCacheMiss: true)
                XCTAssertNil(actual)
            }
        }
    }

    // MARK: - Test ModelReadCache.getValues(for:, transaction:)

    func testGetUncachedMultipleValuesThatExist() {
        let addresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        for address in addresses {
            adapter.storage[address] = OWSUserProfile(address: address)
        }
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                let keys = addresses.map { adapter.cacheKey(forKey: $0) }
                let actual = cache.getValues(for: keys, transaction: transaction)
                let expected = addresses.map { adapter.storage[$0] }
                XCTAssertEqual(actual, expected)
            }
        }
    }

    func testGetMultipleValuesThatDoNotExist() {
        let addresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                let keys = addresses.map { adapter.cacheKey(forKey: $0) }
                let actual = cache.getValues(for: keys, transaction: transaction)
                XCTAssertEqual(actual, [nil, nil])
            }
        }
    }

    func testGetCachedMultipleValues() {
        let addresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        for address in addresses {
            adapter.storage[address] = OWSUserProfile(address: address)
        }
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                let keys = addresses.map { adapter.cacheKey(forKey: $0) }
                for (key, address) in zip(keys, addresses) {
                    cache.writeToCache(cacheKey: key, value: adapter.storage[address]!)
                }
                // Remove addresses from DB to test that they come from cache.
                adapter.storage = [:]
                let actual = cache.getValues(for: keys, transaction: transaction)
                let expected = addresses.map { OWSUserProfile(address: $0) }
                XCTAssertEqual(actual.map { $0?.serviceIdString }, expected.map { $0.serviceIdString })
            }
        }
    }

    func testGetMixOfCachedAndUncachedAndUnknownValues() {
        let storedAddresses: [OWSUserProfile.Address] = [
            .otherUser(SignalServiceAddress.randomForTesting()),
            .otherUser(SignalServiceAddress.randomForTesting()),
        ]
        for address in storedAddresses {
            adapter.storage[address] = OWSUserProfile(address: address)
        }
        // Add a bogus address to test querying a nonexistent key.
        let addresses: [OWSUserProfile.Address] = storedAddresses + [.otherUser(SignalServiceAddress.randomForTesting())]
        read { [unowned self] transaction in
            let cache = TestableModelReadCache(mode: .read, adapter: adapter, appReadiness: AppReadinessMock())
            cache.performSync {
                cache.writeToCache(
                    cacheKey: adapter.cacheKey(forKey: addresses[0]),
                    value: adapter.storage[addresses[0]]!
                )
                let keys = addresses.map { adapter.cacheKey(forKey: $0) }
                let actual = cache.getValues(for: keys, transaction: transaction)
                let expected = addresses.map { adapter.storage[$0] }
                XCTAssertEqual(actual, expected)
            }
        }
    }
}
