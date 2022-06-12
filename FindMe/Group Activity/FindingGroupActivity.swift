//
//  FindingGroupActivity.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import Foundation
import GroupActivities
import SwiftUI

struct FindingActivity: GroupActivity {
    static let activityIdentifier = "com.joogps.FindMe.finding"
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .generic
        metadata.title = "Play FindMe"
        metadata.subtitle = "Have fun in a game of hide and seek."
        
        return metadata
    }
}
