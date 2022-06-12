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
            HStack(spacing: 16) {
                Text("People")
                    .font(.title.bold())
                    .fixedSize()
                Spacer()
                
                if finding.groupSession == nil {
                    Button("SharePlay") {
                        Task {
                            do {
                                let _ = try await FindingActivity().activate()
                            } catch {
                                
                            }
                        }
                    }.buttonStyle(ProminentButtonStyle())
                } else {
                    Button("Start game") {
                        let finder = finding.people.randomElement()!
                        finding.game = Game(finder: finder)
                        finding.sendGame()
                    }.buttonStyle(ProminentButtonStyle())
                }
            }.padding(24)
            .background(.white.opacity(0.05))
            
            LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 2)) {
                ForEach(finding.people) { person in
                    PersonView(person: person)
                        .transition(.scale)
                }
            }.padding(24)
            
            Spacer()
        }
            .animation(.spring(), value: finding.people)
    }
}

struct PersonView: View {
    let person: Person
    
    var body: some View {
        ZStack {
            Capsule().fill(.white)
            Text(person.name)
                .foregroundColor(.accentColor)
                .allowsTightening(true)
                .minimumScaleFactor(0.5)
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
                .fill(Color.accentColor.shadow(.inner(color: .white.opacity(0.25), radius: 4, y: 2)))
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.clear.shadow(.inner(color: .accentColor.opacity(1.0), radius: 4, y: -4)))
                .saturation(50.0)
                .brightness(50.0)
            configuration.label
                .font(.title2.bold())
                .shadow(radius: 0, y: -1)
        }.elastic(active: configuration.isPressed)
            .frame(height: 60)
    }
}
