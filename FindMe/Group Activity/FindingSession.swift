//
//  FindingSession.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI
import GroupActivities
import Combine
import MapKit

enum GameState {
    case waitingForPlayers
    case selectingLocation
    case waitingForOthersToGuess
    case timeLimitUp
}

class FindingSession: ObservableObject {
    @Published var groupSession: GroupSession<FindingActivity>?
    
    var messenger: GroupSessionMessenger?
    
    @Published var people: [Person] = []
    
    @Published var peopleToAddNextRound: [Person] = []
    
    @Published var me: Person?
    
    @Published var game: Game?
    
    @Published var guesses: [Guess] = []
    
    @Published var gameState: GameState = .waitingForPlayers
    
    var subscriptions = Set<AnyCancellable>()
    var tasks = Set<Task<(), Never>>()
    
    func configureGroupSession(_ groupSession: GroupSession<FindingActivity>) async {
        DispatchQueue.main.async {
            self.groupSession = groupSession
            
            self.me = Person(id: groupSession.localParticipant.id)
        }
        
        let messenger = GroupSessionMessenger(session: groupSession)
        
        DispatchQueue.main.async {
            self.messenger = messenger
        }
        
        groupSession.$activeParticipants.sink { activeParticipants in
            let newParticipants = activeParticipants.filter( { !Set(self.people.map( { $0.id } )).contains($0.id) } )
            
            Task {
                do {
                    try await messenger.send(self.me, to: .only(newParticipants))
                } catch {
                }
            }
        }.store(in: &subscriptions)
        
        let personTask = Task.detached { [weak self] in
            for await (message, _) in messenger.messages(of: Person.self) {
                await self?.handle(message)
            }
        }
        self.tasks.insert(personTask)
        
        let gameTask = Task.detached { [weak self] in
            for await (message, _) in messenger.messages(of: Game.self) {
                await self?.handle(message)
            }
        }
        self.tasks.insert(gameTask)
        
        groupSession.join()
    }
    
    func handle(_ message: Person) async {
        // we dont want to append new players if the game has already started
        // instead they should be added next round
        if case .waitingForPlayers = gameState {
            people.append(message)
        } else {
            peopleToAddNextRound.append(message)
        }
    }
    
    func handle(_ message: Game) async {
        gameState = .selectingLocation
        game = message
        startGameTimer()
    }
    
    func handle(_ guess: Guess) async {
        guesses.append(guess)
        gameState = .waitingForOthersToGuess
        if guesses.count == people.count {
            gameDidEnd()
        }
    }
    
    var gameTimer: Timer?
    
    func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            switch self.gameState {
            case .selectingLocation, .waitingForOthersToGuess:
                if let game = self.game {
                    if game.endGuessTime.timeIntervalSinceNow <= 0 {
                        self.gameDidEnd()
                    }
                }
            default:
                // this shouldnt run but like if it does then itll just make the game end
                self.gameDidEnd()
            }
        }
    }
    
    func startGame() {
        let newGame = Game(endGuessTime: .now + 90)
        gameState = .selectingLocation
        game = newGame
        startGameTimer()
        if let messenger = messenger {
            Task {
                do {
                    try await messenger.send(newGame)
                } catch {
                    
                }
            }
        }
    }
    
    func gameDidEnd() {
        gameTimer?.invalidate()
        people.append(contentsOf: peopleToAddNextRound)
        gameState = .timeLimitUp
    }
    
    func makeGuess(location: CLLocationCoordinate2D) {
        guard let me = me else { return }
        let guess = Guess(personId: me.id, location: location)
        gameState = .waitingForOthersToGuess
        if let messenger = messenger {
            Task {
                do {
                    try await messenger.send(guess)
                } catch {
                    
                }
            }
        }
    }
}

struct Game: Codable {
    var location: CLLocationCoordinate2D?
    var endGuessTime: Date
}

struct Guess: Codable {
    var personId: UUID
    var location: CLLocationCoordinate2D
}

struct Person: Identifiable, Codable {
    let id: UUID
    var name: String = "Person"
    var color: Color = [Color.blue, Color.yellow, Color.red, Color.green].randomElement()!
}


