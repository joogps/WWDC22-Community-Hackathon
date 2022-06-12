//
//  GameView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var finding: FindingSession
    
    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()
            switch finding.gameState {
            case .selectLocationForOthers:
                VStack {
                    Text("Pick a place")
                    Button("Submit Golden Gate") {
                        finding.selectLocation(location: .init(latitude: 37.73536, longitude: -122.40709))
                    }.buttonStyle(ProminentButtonStyle())
                }
            case .selectorWaitingForGuesses:
                Text("\(finding.guesses.count) guesses")
            case .guessingLocation:
                if let selectedLocation = finding.selectedLocation {
                    VStack {
                        Text("Find the place!")
                        LookAroundView(coordinate: selectedLocation) {
                            Text("Ryan's view")
                        }
                    }
                } else {
                    Text("\(finding.selector?.name ?? "Someone") is selecting a place")
                        .bold()
                }
            case .guesserWaitingForOthers:
                Text("\(finding.guesses.count) guesses")
            case .waitingForSelector:
                Text("Someone is picking a place")
            case .timeLimitUp:
                Text("Done! guesses: \(finding.guesses.description)")
            
            // This will only be in the lobby
            case .waitingForPlayers:
                EmptyView()
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
