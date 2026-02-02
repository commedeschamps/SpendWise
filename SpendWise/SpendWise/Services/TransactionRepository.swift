import Foundation

protocol TransactionRepository {
    func listenTransactions(completion: @escaping (Result<[Transaction], Error>) -> Void)
    func addTransaction(_ transaction: Transaction, completion: @escaping (Result<Void, Error>) -> Void)
    func updateTransaction(_ transaction: Transaction, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteTransaction(id: String, completion: @escaping (Result<Void, Error>) -> Void)
}
