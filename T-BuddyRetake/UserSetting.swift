//
//  UserSetting.swift
//  T-BuddyRetake
//
//  Created by Noah McGuire on 5/5/25.
//

import Foundation
import SwiftData

@Model
class UserSetting {
    var preferredLine: String
    init(preferredLine: String = "Green-D") {
        self.preferredLine = preferredLine
    }
}
