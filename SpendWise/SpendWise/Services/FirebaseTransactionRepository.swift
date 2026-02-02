import Foundation
import FirebaseDatabase

final class FirebaseTransactionRepository: TransactionRepository {
    private let rootRef: DatabaseReference
    private let userId: String
    private var handle: DatabaseHandle?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(userId: String? = nil, database: DatabaseReference = Database.database().reference()) {
        self.rootRef = database
        if let provided = userId {
            self.userId = provided
        } else if let stored = UserDefaults.standard.string(forKey: "SpendWiseUserId") {
            self.userId = stored
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: "SpendWiseUserId")
            self.userId = newId
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        self.decoder = decoder
    }

    deinit {
        if let handle {
            transactionsRef().removeObserver(withHandle: handle)
        }
    }

    func listenTransactions(completion: @escaping (Result<[Transaction], Error>) -> Void) {
        handle = transactionsRef().observe(
            .value,
            with: { [weak self] snapshot in
                guard let self else { return }
                var items: [Transaction] = []

                for child in snapshot.children {
                    guard let child = child as? DataSnapshot,
                          var dict = child.value as? [String: Any] else { continue }
                    dict["id"] = child.key
                    if let transaction = self.decode(dict) {
                        items.append(transaction)
                    }
                }

                completion(.success(items))
            },
            withCancel: { error in
                completion(.failure(error))
            }
        )
    }

    func addTransaction(_ transaction: Transaction, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let payload = encode(transaction) else {
            completion(.failure(RepositoryError.encodingFailed))
            return
        }

        transactionsRef().child(transaction.id).setValue(payload) { error, _ in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func updateTransaction(_ transaction: Transaction, completion: @escaping (Result<Void, Error>) -> Void) {
        addTransaction(transaction, completion: completion)
    }

    func deleteTransaction(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        transactionsRef().child(id).removeValue { error, _ in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    private func transactionsRef() -> DatabaseReference {
        rootRef.child("users").child(userId).child("transactions")
    }

    private func encode(_ transaction: Transaction) -> [String: Any]? {
        guard let data = try? encoder.encode(transaction),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }

    private func decode(_ dict: [String: Any]) -> Transaction? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict) else {
            return nil
        }
        return try? decoder.decode(Transaction.self, from: data)
    }
}

enum RepositoryError: Error {
    case encodingFailed
}
