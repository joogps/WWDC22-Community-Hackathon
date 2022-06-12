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
            if finding.game?.finder == finding.me {
                if let location = finding.game?.location {
                    Text("\(finding.game?.guesses.count ?? 0) guesses")
                } else {
                    VStack {
                        Text("Pick a place")
                        Button("Submit Golden Gate") {
                            finding.game?.location = .init(latitude: 37.73536, longitude: -122.40709)
                            finding.sendGame()
                        }.buttonStyle(ProminentButtonStyle())
                    }
                }
            } else {
                if let location = finding.game?.location {
                    VStack {
                        Text("Find the place!")
                        LookAroundView(coordinate: location) {
                            Text("Ryan's view")
                        }
                    }
                } else if let picker = finding.game?.finder {
                    Text("\(picker.name) is picking a place")
                        .bold()
                }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
