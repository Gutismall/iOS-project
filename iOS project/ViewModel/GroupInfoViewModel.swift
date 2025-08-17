struct GroupStatistic {
    let title: String
    let description: String
}

struct GroupInfoViewModel {
    let group: Group

    var statistics: [GroupStatistic] {
        let totalCharges = GroupStatistic(
            title: "Total Charges",
            description: "\(group.charges.count)"
        )

        let totalAmount = GroupStatistic(
            title: "Total Amount",
            description: "\(group.charges.reduce(0) { $0 + $1.amount })"
        )

        let averageAmount = GroupStatistic(
            title: "Average Charge",
            description: group.charges.isEmpty ? "0" : "\(group.charges.reduce(0) { $0 + $1.amount } / Double(group.charges.count))"
        )

        let mostAddedCategory = GroupStatistic(
            title: "Most Added Category",
            description: (
                Dictionary(group.charges.map { ($0.category, 1) }, uniquingKeysWith: +)
                    .max(by: { $0.value < $1.value })?.key.rawValue ?? "N/A"
            )
        )

        let mostActiveUser = GroupStatistic(
            title: "Most Active User",
            description: (
                Dictionary(group.charges.map { ($0.createdByName, 1) }, uniquingKeysWith: +)
                .max(by: { $0.value < $1.value })?.key ?? "N/A"
            )
        )

        let topCharges = GroupStatistic(
            title: "Top 3 Charges",
            description: (
                group.charges
                    .sorted { $0.amount > $1.amount }
                    .prefix(3)
                    .map { "\($0.amount) \($0.description)" }
                    .joined(separator: ", ")
            )
        )

        return [
            totalCharges,
            totalAmount,
            averageAmount,
            mostAddedCategory,
            mostActiveUser,
            topCharges
        ]
    }
}
