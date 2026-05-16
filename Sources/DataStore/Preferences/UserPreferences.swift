
import Foundation
import Observation

public enum Ayanamsa: Int, CaseIterable {
    case lahiri = 1
    case raman = 3
    case kp = 5
    
    public var displayName: String {
        switch self {
        case .lahiri:
            return "Lahiri"
        case .raman:
            return "Raman"
        case .kp:
            return "KP Astrology"
        }
    }
    
    public static var defaultValue: Ayanamsa {
        .lahiri
    }
}

public enum CalendarDateDisplayType: String, CaseIterable {
    case tamil
    case malayalam
    case shakaSamwat = "shaka-samvat"
    case vikarmSamvat = "vikram-samvat"
    case amanta
    case purnimanta
    case gujarati
    case bengali
    case lunar
}


@Observable @MainActor
public class UserPreferences {
    
    private let userDefaults = UserDefaults(suiteName: "group.pocketpanchang")!
    @MainActor public static let shared: UserPreferences = .init()
    enum PreferenceKeys {
        static let selectedCalendar: String = "selectedCalendar"
        static let selectedAyanamsa: String = "selectedAyanamsa"
    }
    
    public var currentAyanamsa: Ayanamsa {
        didSet {
            print("current ayanamasa is now \(currentAyanamsa)")
            userDefaults.set(currentAyanamsa.rawValue, forKey: PreferenceKeys.selectedAyanamsa)
        }
    }
    
    var currentCalendar: CalendarDateDisplayType {
        didSet {
            userDefaults.set(currentCalendar.rawValue, forKey: PreferenceKeys.selectedCalendar)
        }
    }
        
    private init() {
        Self.registerDefaults()
        let storedAyanamsa = userDefaults.integer(forKey: PreferenceKeys.selectedAyanamsa)
        currentAyanamsa = Ayanamsa(rawValue: storedAyanamsa)!
        let storedCalendar = userDefaults.string(forKey: PreferenceKeys.selectedCalendar)!
        currentCalendar = CalendarDateDisplayType(rawValue: storedCalendar)!
    }
    
    private static func registerDefaults(userDefaults: UserDefaults = .standard) {
        let defaultValues: [String: Any] = [
            PreferenceKeys.selectedCalendar: CalendarDateDisplayType.shakaSamwat.rawValue,
            PreferenceKeys.selectedAyanamsa: Ayanamsa.defaultValue.rawValue
        ]
        userDefaults.register(defaults: defaultValues)
    }
}


