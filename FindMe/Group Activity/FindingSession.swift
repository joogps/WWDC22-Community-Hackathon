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
    
    // When you are the selector, and you need to select a location for others to guess.
    case selectLocationForOthers
    
    // When you are a guesser, and you are waiting for the selector to select a location.
    case waitingForSelector
    
    // When you are a selector, and you are waiting for guessers to find your location.
    case selectorWaitingForGuesses
    
    // When you are a guesser, and you are guessing the location that the selector selected.
    case guessingLocation
    
    // When you are a guesser, and you are waiting for others to make their guesses.
    case guesserWaitingForOthers
    
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
            self.people.append(self.me!)
        }
        
        let messenger = GroupSessionMessenger(session: groupSession)
        self.messenger = messenger
        
        groupSession.$activeParticipants.sink { activeParticipants in
            let newParticipants = activeParticipants.filter( { !Set(self.people.map { person in
                person.id
            }).contains($0.id) } )
            
            if let me = self.me {
                Task {
                    print("Sending new participants")
                    do {
                        try await messenger.send(me, to: .all)
                    } catch {
                        
                    }
                }
            }
        }.store(in: &subscriptions)
        
        groupSession.$state.sink { state in
            print("New state: \(state)")
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
        DispatchQueue.main.async {
            // we dont want to append new players if the game has already started
            // instead they should be added next round
            if case .waitingForPlayers = self.gameState {
                self.people.append(message)
                
            } else {
                self.peopleToAddNextRound.append(message)
            }
        }
    }
    
    func handle(_ message: Game) async {
        game = message
        
        if message.location == nil {
            if message.locationSelector.id == me?.id {
                gameState = .selectLocationForOthers
            } else {
                gameState = .waitingForSelector
            }
        } else {
            if message.locationSelector.id == me?.id {
                gameState = .selectorWaitingForGuesses
            } else {
                gameState = .guessingLocation
            }
            
            startGameTimer()
        }
    }
    
    func handle(_ guess: Guess) async {
        guesses.append(guess)
        if guesses.count == people.count {
            gameDidEnd()
        }
    }
    
    var gameTimer: Timer?
    
    func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let game = self.game {
                if (game.endGuessTime?.timeIntervalSinceNow ?? 0) <= 0 {
                    self.gameDidEnd()
                }
            }
        }
    }
    
    func startGame() {
        let selector = people.randomElement()!
        let newGame = Game(locationSelector: selector, endGuessTime: .now + 90)
        
        if selector.id == me?.id {
            gameState = .selectLocationForOthers
        } else {
            gameState = .waitingForSelector
        }
        
        game = newGame
        
        if let messenger = messenger {
            Task {
                do {
                    try await messenger.send(newGame)
                } catch {
                    
                }
            }
        }
    }
    
    // this will ONLY be run by selectors
    func selectLocation(location: CLLocationCoordinate2D) {
        guard let me = me else { return }
        let location = SelectorLocation(location: location)
        gameState = .selectorWaitingForGuesses
        if let messenger = messenger {
            Task {
                do {
                    try await messenger.send(location)
                } catch {
                }
            }
        }
    }
    
    // this will ONLY be run by guessers
    func makeGuess(location: CLLocationCoordinate2D) {
        guard let me = me else { return }
        let guess = Guess(personId: me.id, location: location)
        gameState = .guesserWaitingForOthers
        if let messenger = messenger {
            Task {
                do {
                    try await messenger.send(guess)
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
    
    func leaveSession() {
        messenger = nil
        
        tasks.forEach( { $0.cancel() } )
        tasks = []
        subscriptions = []
        
        if groupSession != nil {
            groupSession?.leave()
            groupSession = nil
        }
    }
}

struct Game: Codable {
    var locationSelector: Person
    var endGuessTime: Date
}

struct SelectorLocation: Codable {
    var location: CLLocationCoordinate2D
}

struct Guess: Codable {
    var personId: UUID
    var location: CLLocationCoordinate2D
}

struct Person: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String = UIDevice.current.name
    // var color: Color = [Color.blue, Color.yellow, Color.red, Color.green].randomElement()!
}
