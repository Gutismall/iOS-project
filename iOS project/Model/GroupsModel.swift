import Foundation
import UIKit

struct Group{
    let id: String
    var name: String
    var members: [userNameAndIcon]
    var groupIcon: String
    let activities: [Activity]
    var charges: [Charge]
    var totalExpenses: Double{
        var total: Double = 0
        charges.forEach(){ charge in
            total += charge.amount
        }
        return total
    }
}

struct userNameAndIcon {
    let userName: String
    let userIconUrl: String
}
