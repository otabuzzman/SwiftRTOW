import Foundation

public enum FsmError: Error {
    case unexpectedError
    case unexpectedFsmState
    case unexpectedFsmEvent
}

extension FsmError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unexpectedError:
            return NSLocalizedString("unexpected error", comment: "")
        case .unexpectedFsmState:
            return NSLocalizedString("unexpected FSM state", comment: "")
        case .unexpectedFsmEvent:
            return NSLocalizedString("unexpected FSM event", comment: "")
        }
    }
}
