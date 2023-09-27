import Foundation

class Game {
    var map: [Map] = []
    var players: [Player] = []
    var currentRound: Int = 0
    let maxRounds: Int = 31
    var isGameFinished: Bool = false
    var terroristRoundsWon: Int = 0
    var spetsnazRoundsWon: Int = 0
    let maxRoundsToWin: Int = 16
    var playerNames: [String] = []
    var roundInProgress: Bool = false

    init(playerNames: [String]) {
        self.playerNames = playerNames
        generateRandomPlayers()
    }

    func managerGame() {
        generateRandomMap()
    }

    func generateRandomMap() {
        if let randomMapType = MapType.allCases.randomElement() {
            let map = Map(type: randomMapType)
            self.map.append(map)
        }
    }

    func startGame() {
        while currentRound < maxRounds && !isGameFinished {
            if !roundInProgress {
                
                managerGame()
                roundInProgress = true
            }

            var roundTime = map.last?.type.timerDuration ?? 0

            print("Round \(currentRound + 1) started!")
            while !checkRoundFinished(roundTime: &roundTime) {
                randomPlayerEncounter()
                roundTime -= 1
            }
            calculateBonusPoints()
            printPlayerScores()
            printRoundWinner()

            currentRound += 1
            roundInProgress = false
        }

        printGameWinner()
    }

    func generateRandomPlayers() {
        
        self.players.removeAll()

        for playerName in playerNames {
            var player = Player(name: playerName)
            player.team = Team.allCases.randomElement()
            player.weapons = generateRandomWeapons()
            self.players.append(player)
        }
    }

    func generateRandomWeapons() -> [Weapon] {
        var randomWeapons: [Weapon] = []
        for _ in 0..<2 {
            if let weapon = Weapon.allCases.randomElement() {
                randomWeapons.append(weapon)
            }
        }
        return randomWeapons
    }

    func checkRoundFinished(roundTime: inout TimeInterval) -> Bool {
        let teams = Set(self.players.map { $0.team })
        for team in teams {
            let teamPlayers = self.players.filter { $0.team == team }
            if teamPlayers.allSatisfy({ $0.isDead }) || roundTime <= 0 {
                return true
            }
        }
        return false
    }

    func randomPlayerEncounter() {
        var player1 = getRandomPlayer()
        var player2 = getRandomPlayer()
        if player1.team != player2.team {
            player1.fire(target: &player2)
        }
    }

    func getRandomPlayer() -> Player {
        return self.players.randomElement()!
    }

    func calculateBonusPoints() {
        let teams = Set(self.players.map { $0.team })
        for team in teams {
            let teamPlayers = self.players.filter { $0.team == team }
            if teamPlayers.allSatisfy({ $0.isDead }) {
                let survivors = teamPlayers.filter { !$0.isDead }
                for var survivor in survivors {
                    survivor.score += 5
                }
                if team == .terrorist {
                    terroristRoundsWon += 1
                } else {
                    spetsnazRoundsWon += 1
                }
            }
        }
    }

    func printPlayerScores() {
        print("Список игроков и их очков:")
        for player in self.players {
            print("\(player.name): \(player.score) очков")
        }
    }

    func printRoundWinner() {
        if terroristRoundsWon > spetsnazRoundsWon {
            print("Round \(currentRound) winner: Terrorists")
        } else if terroristRoundsWon < spetsnazRoundsWon {
            print("Round \(currentRound) winner: Spetsnaz")
        } else {
            print("Round \(currentRound) ended in a draw")
        }
    }

    func printGameWinner() {
        if terroristRoundsWon > spetsnazRoundsWon {
            print("Game winner: Terrorists")
        } else if terroristRoundsWon < spetsnazRoundsWon {
            print("Game winner: Spetsnaz")
        } else {
            print("Game ended in a draw")
        }
    }
}

class Map {
    var type: MapType 

    init(type: MapType) {
        self.type = type
    }
}

struct Player {
    var name: String
    var team: Team?
    var weapons: [Weapon] = []
    var score: Int = 0
    var health: Int = 100

    mutating func fire(target: inout Player) {
        for weapon in weapons {
            let damage = weapon.damage
            target.applyDamage(damage)
            if target.isDead {
                self.score += 3
            }
        }
    }

    mutating func applyDamage(_ damage: Int) {
        self.health -= damage
    }

    var isDead: Bool {
        return health <= 0
    }
}

enum MapType: CaseIterable {
    case dust2
    case mirage
    case inferno
    case nuke

    var timerDuration: TimeInterval {
        switch self {
        case .dust2:
            return 100
        case .mirage:
            return 120
        case .inferno:
            return 130
        case .nuke:
            return 140
        }
    }
}

enum Team: CaseIterable {
    case terrorist
    case spetsnaz
}

enum Weapon: CaseIterable {
    case pistolet
    case kalash
    case m16
    case slonoboy

    var damage: Int {
        switch self {
        case .pistolet:
            return 10
        case .kalash:
            return 20
        case .m16:
            return 30
        case .slonoboy:
            return 100
        }
    }
}
