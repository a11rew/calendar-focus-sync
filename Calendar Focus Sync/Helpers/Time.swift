func timeBufferToSeconds(_ timeBuffer: TimeBefore.RawValue) -> Int {
    switch timeBuffer {
        case TimeBefore.one_minute.rawValue:
            return 60
        case TimeBefore.five_minutes.rawValue:
            return 60 * 5
        case TimeBefore.ten_minutes.rawValue:
            return 60 * 10
        default:
            return 0
    }
}
