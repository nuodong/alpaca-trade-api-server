/// Type-erased Encodable to keep `sendJSON` ergonomic.
nonisolated public struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    public init<T: Encodable>(_ value: T) { self.encodeFunc = value.encode }
    public func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}
