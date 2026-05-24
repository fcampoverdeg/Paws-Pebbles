import Foundation
import Security
import LocalAuthentication

class AuthService {
    static let shared = AuthService()
    private let pinKey = "com.pawsandpebbles.pin"

    private init() {}

    // MARK: - PIN Management (Keychain)

    func savePin(_ pin: String) {
        deletePin()
        let data = pin.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: pinKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    func verifyPin(_ pin: String) -> Bool {
        guard let storedPin = getPin() else { return false }
        return pin == storedPin
    }

    func hasPin() -> Bool {
        return getPin() != nil
    }

    private func getPin() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: pinKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deletePin() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: pinKey
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Face ID

    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(false)
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                              localizedReason: "Unlock Paws & Pebbles") { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
