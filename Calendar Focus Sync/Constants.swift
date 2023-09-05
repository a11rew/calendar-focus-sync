enum TimeBefore {
    case one_minute
    case two_minutes
    case five_minutes
    case ten_minutes
    
    var rawValue: Int {
        switch self {
        case .one_minute:
            return 1
        case .two_minutes:
            return 2
        case .five_minutes:
            return 5
        case .ten_minutes:
            return 10
        }
    }
    
    typealias RawValue = Int
}
