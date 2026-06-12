import SwiftUI

struct HeightCategory: Identifiable, Codable, Equatable {
    let id: String
    let label: String
    let minMetres: Float
    let maxMetres: Float
    let systemIcon: String
    let colorName: String

    var color: Color {
        switch colorName {
        case "green":  return .green
        case "blue":   return .blue
        case "orange": return .orange
        case "red":    return .red
        default:       return .gray
        }
    }

    func contains(_ height: Float) -> Bool {
        height >= minMetres && height < maxMetres
    }

    static let defaults: [HeightCategory] = [
        HeightCategory(id: "micro",  label: "Micro",           minMetres: 0,    maxMetres: 0.10, systemIcon: "smallcircle.filled.circle", colorName: "gray"),
        HeightCategory(id: "small",  label: "Small",           minMetres: 0.10, maxMetres: 0.30, systemIcon: "cube",                     colorName: "green"),
        HeightCategory(id: "medium", label: "Medium",          minMetres: 0.30, maxMetres: 1.00, systemIcon: "shippingbox",              colorName: "blue"),
        HeightCategory(id: "tall",   label: "Tall",            minMetres: 1.00, maxMetres: 2.00, systemIcon: "person.fill",              colorName: "orange"),
        HeightCategory(id: "large",  label: "Large Structure", minMetres: 2.00, maxMetres: 999,  systemIcon: "building.2",               colorName: "red"),
    ]

    static func category(for height: Float, categories: [HeightCategory] = defaults) -> HeightCategory {
        categories.first { $0.contains(height) } ?? categories.last!
    }
}
