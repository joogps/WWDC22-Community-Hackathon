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
            Rectangle()
                .fill(Color.accentColor.gradient)
                .ignoresSafeArea()
            
            Group {
                switch finding.gameState {
                case .selectLocationForOthers:
                    SelectView()
                case .selectorWaitingForGuesses:
                    Text("\(finding.guesses.count) guesses have already been made.")
                case .guessingLocation:
                    ZStack {
                        Rectangle()
                            .fill(.linearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom))
                            .ignoresSafeArea()
                        
                        VStack {
                            Text("Tap below to explore!")
                                .font(.custom("SF Pro Expanded Bold", size: 20))
                                .foregroundColor(.white)
                            if let selectedLocation = finding.selectedLocation {
                                LookAroundView(coordinate: selectedLocation) {
                                    GuessingView()
                                        .environmentObject(finding)
                                }
                            }
                        }
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
            .transition(.opacity)
            .animation(.spring(), value: finding.gameState)
        }
    }
}

struct GuessAccomplishment: View {
    @EnvironmentObject var finding: FindingSession
    
    var body: some View {
        VStack {
            Text("Godd guess!")
                .font(.custom("SF Pro Expanded Heavy", size: 28))
            Text("\(finding.people.count-finding.guesses.count) players are yet to make theirs.")
                .font(.custom("SF Pro Expanded Bold", size: 20))
        }.padding(64)
    }
}

struct WaitingTitle: View {
    @EnvironmentObject var finding: FindingSession
    
    var body: some View {
        VStack {
            Text("\(finding.selector?.name ?? "Someone") is picking a place")
                .font(.custom("SF Pro Expanded Bold", size: 20))
            Rectangle()
                .fill(.white)
                .opacity(0.5)
                .frame(height: 2)
        }.padding(64)
            .multilineTextAlignment(.center)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
