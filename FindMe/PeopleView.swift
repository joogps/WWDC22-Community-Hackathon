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
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .fixedSize()
                    
                    if finding.groupSession == nil {
                        Button("Start") {
                            Task {
                                do {
                                    let _ = try await FindingActivity().activate()
                                } catch {
                                    
                                }
                            }
                        }.buttonStyle(ProminentButtonStyle())
                    } else {
                        if finding.game == nil {
                            Button("Start game") {
                                let finder = finding.people.randomElement()!
                                finding.game = Game(finder: finder)
                                finding.sendGame()
                            }.buttonStyle(ProminentButtonStyle())
                        }
                    }
                }
                
                Spacer()
            }
            
            LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 2)) {
                ForEach(finding.people) { person in
                    PersonView(person: person)
                }
            }
            
            Spacer()
        }.padding(32)
    }
}

struct PersonView: View {
    let person: Person
    
    var body: some View {
        ZStack {
            Capsule().fill(Color.accentColor)
            Label(person.name, systemImage: "person.fill")
                .bold()
                .padding()
        }
    }
}

extension View {
    func sheetStyle() -> some View {
        Rectangle().fill(Material.ultraThinMaterial)
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

/// Button
public extension View {
    func elastic(active: Bool) -> some View {
        self.modifier(ElasticModifier(active: active))
    }
}

struct ElasticModifier: ViewModifier {
    var active: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 0.9 : 1.0)
            .animation(.spring(), value: active)
    }
}


public struct ElasticButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.elastic(active: configuration.isPressed)
    }
}

public struct ProminentButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.accentColor.shadow(.inner(color: .white.opacity(0.25), radius: 3, y: 3)))
                .frame(height: 60)
            configuration.label
                .font(.headline.bold())
        }.elastic(active: configuration.isPressed)
    }
}
