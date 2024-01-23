//
//  KeychainManager.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2024-01-19.
//

import Foundation
import KeychainAccess

class KeychainManager {
	private let keychain = Keychain(
		service: Keys.keychainService,
		accessGroup: Keys.keychainGroup
	)
	
	enum KeychainKeys: String { case email, password }
	
	public func saveItems(
		_ items: [(key: KeychainKeys, value: String)]
	) throws {
		for item in items {
			try keychain.set(item.value, key: item.key.rawValue)
		}
	}
	
	public func getItem(
		withKey key: KeychainKeys
	) throws -> String? {
		return try keychain.get(key.rawValue)
	}
}
