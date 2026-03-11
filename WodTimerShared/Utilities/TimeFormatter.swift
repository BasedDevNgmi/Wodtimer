import Foundation

public enum TimeFormatter {
    /// Formats seconds as "MM:SS"
    public static func mmss(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Formats seconds as "H:MM:SS" if >= 1 hour, otherwise "MM:SS"
    public static func adaptive(_ totalSeconds: Int) -> String {
        if totalSeconds >= 3600 {
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return mmss(totalSeconds)
    }

    /// Formats seconds as "M" for display (e.g. "10" for 600 seconds)
    public static func minutesOnly(_ totalSeconds: Int) -> String {
        return "\(totalSeconds / 60)"
    }

    /// Formats TimeInterval as "MM:SS.t" with tenths
    public static func precise(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let tenths = Int((interval - Double(total)) * 10)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
}
