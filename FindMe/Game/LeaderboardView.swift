//
//  LeaderboardView.swift
//  FindMe
//
//  Created by Ryan D on 6/12/22.
//

import SwiftUI
import Charts
import CoreLocation

struct LeaderboardView: View {
    @EnvironmentObject var finding: FindingSession
    var body: some View {
        Chart {
            ForEach(finding.guesses) { guess in
                BarMark(y: .value(guess.person.name, calculateDistance(guess: guess.location, location: finding.location ?? .init(latitude: 0, longitude: 0))))
            }
        }
    }
    
    func calculateDistance(guess: CLLocationCoordinate2D, location: CLLocationCoordinate2D) -> Double {
        return sqrt(pow(guess.longitude - location.longitude, 2) + pow(guess.latitude - location.latitude, 2))
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
