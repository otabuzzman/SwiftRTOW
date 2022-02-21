import Foundation

public enum FsmError: Error {
    case unexpectedEvent
}

extension FsmError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unexpectedEvent:
            return NSLocalizedString("unexpected event", comment: "")
        }
    }
}
