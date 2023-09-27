import Foundation

class TimerGame {
    private var timer: Timer?
    private var game: Game
    private var currentRound: Int = 0
    private let maxRounds: Int = 31
   
    init(game: Game) {
        self.game = game
    }
    
    func startGame() {
        startRound()
    }
    
    private func startRound() {
        guard currentRound < maxRounds else {
            endGame()
            return
        }
        
        game.managerGame()
        currentRound += 1
        print("Round \(currentRound) started!")
        
        var roundTime = game.map.last?.type.timerDuration ?? 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            roundTime -= 1
            if roundTime <= 0 {
                self.endRound()
            }
        }
    }
    
    private func checkRoundCompletion() {
        let teams = Set(game.players.map { $0.team })
        for team in teams {
            let teamPlayers = game.players.filter { $0.team == team }
            if teamPlayers.allSatisfy({ $0.isDead }) {
                endRound()
                return
            }
        }
    }
    
    private func endRound() {
        timer?.invalidate()
        timer = nil
        print("Round \(currentRound) ended!")

        game.calculateBonusPoints()
        game.printPlayerScores()

        if currentRound < maxRounds {
            currentRound += 1
            print("Round \(currentRound) started!")
            startRound()
        } else {
            endGame()
        }
    }

    private func endGame() {
        timer?.invalidate()
        timer = nil
        print("Game over!")
    }
}
