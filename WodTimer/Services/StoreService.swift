import Foundation
import StoreKit

enum StoreError: Error, LocalizedError {
    case productNotFound
    case purchaseFailed
    case cancelled
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Product not found in App Store"
        case .purchaseFailed: return "Purchase failed. Please try again."
        case .cancelled: return "Purchase was cancelled"
        case .verificationFailed: return "Purchase verification failed"
        }
    }
}

@Observable
final class StoreService {
    static let shared = StoreService()

    var isPremium: Bool = false
    private var product: Product?
    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await checkEntitlements() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [AppConstants.premiumProductId])
            product = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase() async throws {
        guard let product else {
            throw StoreError.productNotFound
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            isPremium = true
            await transaction.finish()

        case .userCancelled:
            throw StoreError.cancelled

        case .pending:
            break

        @unknown default:
            throw StoreError.purchaseFailed
        }
    }

    // MARK: - Restore

    func restorePurchases() async throws -> Bool {
        try await AppStore.sync()
        await checkEntitlements()
        return isPremium
    }

    // MARK: - Entitlements

    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == AppConstants.premiumProductId {
                    isPremium = transaction.revocationDate == nil
                    return
                }
            }
        }
        isPremium = false
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    if transaction.productID == AppConstants.premiumProductId {
                        self.isPremium = transaction.revocationDate == nil
                    }
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}
