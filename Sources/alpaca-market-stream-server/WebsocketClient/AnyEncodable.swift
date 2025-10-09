/// Type-erased Encodable to keep `sendJSON` ergonomic.
nonisolated struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) { self.encodeFunc = value.encode }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}
