import Foundation
import Security

public enum KeychainManager: Sendable {
    private static let serviceName = "com.growatt.toolbar"
    private static let accountName = "api-key"

    private static var baseQuery: [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: accountName,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecAttrSynchronizable: kCFBooleanFalse as Any
        ]
    }

    public static func save(key: String) throws {
        guard let data = key.data(using: .utf8) else {
            throw GrowattAPIError.keychainError("Failed to encode API key as UTF-8 data")
        }

        var addQuery = baseQuery
        addQuery[kSecValueData] = data

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)

        if addStatus == errSecSuccess {
            return
        }

        if addStatus == errSecDuplicateItem {
            let updateAttributes: [CFString: Any] = [
                kSecValueData: data
            ]
            let updateStatus = SecItemUpdate(baseQuery as CFDictionary, updateAttributes as CFDictionary)
            if updateStatus != errSecSuccess {
                throw GrowattAPIError.keychainError("Failed to update API key (OSStatus \(updateStatus))")
            }
            return
        }

        throw GrowattAPIError.keychainError("Failed to save API key (OSStatus \(addStatus))")
    }

    public static func read() throws -> String? {
        var query = baseQuery
        query[kSecReturnData] = kCFBooleanTrue as Any
        query[kSecMatchLimit] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess, let data = result as? Data else {
            throw GrowattAPIError.keychainError("Failed to read API key (OSStatus \(status))")
        }

        return String(data: data, encoding: .utf8)
    }

    public static func delete() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            return
        }

        throw GrowattAPIError.keychainError("Failed to delete API key (OSStatus \(status))")
    }
}
