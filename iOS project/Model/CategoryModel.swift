import UIKit

enum ChargeCategory: String, Codable, CaseIterable {
    case food
    case travel
    case shopping
    case transport
    case accommodation
    case other

    var icon: UIImage {
        switch self {
        case .food: return UIImage(systemName: "fork.knife")!
        case .travel: return UIImage(systemName: "airplane")!
        case .shopping: return UIImage(systemName: "bag")!
        case .transport: return UIImage(systemName: "car")!
        case .accommodation: return UIImage(systemName: "bed.double")!
        case .other: return UIImage(systemName: "ellipsis")!
        }
    }

    var displayName: String {
        self.rawValue.capitalized
    }
}
