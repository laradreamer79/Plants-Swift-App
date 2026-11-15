

enum Room: String, CaseIterable, Identifiable, Codable{
    case bedroom = "Bedroom"
    case livingroom = "Living Room"
    case kitchen = "kitchen"
    case balconey = "Balcony"
    case Bathroom = "Bathroom"
    
    var id: Self { self }
}

enum WateringDays: String, CaseIterable, Identifiable, Codable{
    case EveryDay = "EveryDay"
    case Every2Days = "Every 2 Days"
    case Every3Days = "Every 3 Days"
    case OnceaWeek = "Once a Week"
    case Every10Days = "Every 10 Days"
    case Every2Weeks = "very 2 Weeks"
    
    var id: Self { self }

}

enum Water: String, CaseIterable, Identifiable, Codable {
    case ml20To50 = "20-50 ml"
    case ml50To100 = "50-100 ml"
    case ml100To200 = "100-200 ml"
    case ml200To300 = "200-300 ml"

    var id: Self { self }
}

enum Light: String, CaseIterable, Identifiable, Codable {
    case fullSun = "Full Sun"
    case partialSun = "Partial Sun"
    case lowLight = "Low Light"

    var id: Self { self }
}


