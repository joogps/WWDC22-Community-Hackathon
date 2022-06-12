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
                Text("Players")
                    .font(.custom("SF Pro Expanded Heavy", size: 28, relativeTo: .title))
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
                        finding.startGame()
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
            
            /* VStack {
                Image(systemName: "figure.walk")
                    .font(.system(size: 64))
                    .padding()
                Text("waiting for other players")
                    .bold()
            }.foregroundStyle(.tertiary) */
            
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
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
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
    
    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        ProminentButton(configuration: configuration)
    }
    
    struct ProminentButton: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.isEnabled) private var isEnabled: Bool
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.accentColor.shadow(.inner(color: .white.opacity(0.25), radius: 4, y: 2)))
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.clear.shadow(.inner(color: .accentColor.opacity(1.0), radius: 4, y: -4)))
                    .saturation(50.0)
                    .brightness(50.0)
                
                configuration.label
                    .font(.title2.weight(.heavy))
                    .shadow(radius: 0, y: -2)
            }.grayscale(isEnabled ? 0 : 1)
            .frame(height: 50)
            .elastic(active: configuration.isPressed)
        }
    }
}
