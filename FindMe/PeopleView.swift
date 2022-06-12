//
//  PeopleView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI
import FontBlaster

struct PeopleView: View {
    @EnvironmentObject var finding: FindingSession
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Players")
                        .font(.system(size: 32, weight: .heavy, design: .default))
                        .fixedSize()
                    
                    if finding.groupSession == nil {
                        Button("Start") {
                            Task {
                                do {
                                    let _ = try await FindingActivity().activate()
                                } catch {
                                    
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 2)) {
                ForEach(0..<6) { person in
                    PersonView()
                }
            }
            
            Spacer()
        }.padding(32)
    }
}

extension View {
    func sheetStyle() -> some View {
        BackgroundClearView()
            .overlay {
                Rectangle()
                    .fill(Material.ultraThinMaterial)
            }
            .overlay {
                self
            }
            .ignoresSafeArea()
            .colorScheme(.dark)
    }
}

struct PeopleView_Previews: PreviewProvider {
    static var previews: some View {
        PeopleView()
    }
}
