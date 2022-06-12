//
//  FindingGroupActivity.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import Foundation
import GroupActivities

struct FindingActivity: GroupActivity {
    static let activityIdentifier = "com.joogps.FindMe.finding"
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .generic
        metadata.title = "Play a finding game"
        metadata.subtitle = "GEINJSDOMzclx"
        
        return metadata
    }
}
