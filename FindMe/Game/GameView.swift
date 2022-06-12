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
                }.padding()
            case .selectorWaitingForGuesses:
                Text("\(finding.guesses.count) guesses have already been made.")
            case .guessingLocation:
                if let selectedLocation = finding.selectedLocation {
                    VStack {
                        Text("Find the place!")
                        LookAroundView(coordinate: selectedLocation) {
                            GuessingView()
                        }
                    }
                } else {
                    Text("\(finding.selector?.name ?? "Someone") is selecting a place")
                        .bold()
                }
            case .guesserWaitingForOthers:
                VStack {
                    Text("Godd guess!")
                        .font(.title2.bold())
                    Text("\(finding.people.count-finding.guesses.count) players are yet to make theirs.")
                }.padding()
            case .waitingForSelector:
                Text("\(finding.selector?.name ?? "Someone") is picking a place")
                    .bold()
            case .timeLimitUp:
                Text("Done! guesses: \(finding.guesses.description)")
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
