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
            Group {
                switch finding.gameState {
                case .selectLocationForOthers:
                    SelectView()
                case .selectorWaitingForGuesses:
                    Text("\(finding.guesses.count) guesses have already been made.")
                case .guessingLocation:
                    if let selectedLocation = finding.selectedLocation {
                        VStack {
                            Text("Tap below to explore!")
                                .font(.custom("SF Pro Expanded Bold", size: 20, relativeTo: .body))
                            LookAroundView(coordinate: selectedLocation) {
                                GuessingView()
                                    .environmentObject(finding)
                            }
                        }
                    } else {
                        WaitingTitle()
                    }
                case .guesserWaitingForOthers:
                    GuessAccomplishment()
                case .waitingForSelector:
                    WaitingTitle()
                case .end:
                    LeaderboardView()
                        .environmentObject(finding)
                case .waitingForPlayers:
                    EmptyView()
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .zIndex(1)
            .animation(.spring(), value: finding.gameState)
        }
    }
}

struct GuessAccomplishment: View {
    @EnvironmentObject var finding: FindingSession
    
    var body: some View {
        VStack {
            Text("Godd guess!")
                .font(.custom("SF Pro Expanded Heavy", size: 28, relativeTo: .title))
            Text("\(finding.people.count-finding.guesses.count) players are yet to make theirs.")
                .font(.custom("SF Pro Expanded Bold", size: 20, relativeTo: .body))
        }.padding()
    }
}

struct WaitingTitle: View {
    @EnvironmentObject var finding: FindingSession
    
    var body: some View {
        Text("\(finding.selector?.name ?? "Someone") is picking a place")
            .font(.custom("SF Pro Expanded Bold", size: 20, relativeTo: .body))
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
