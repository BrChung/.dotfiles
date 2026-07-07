import Foundation

@_silgen_name("setSwipeScrollDirection")
func setSwipeScrollDirection(_ direction: Bool)

let natural = CommandLine.arguments.contains("--natural")
setSwipeScrollDirection(natural)

CFNotificationCenterPostNotification(
    CFNotificationCenterGetDistributedCenter(),
    CFNotificationName("SwipeScrollDirectionDidChangeNotification" as CFString),
    nil,
    nil,
    true
)
