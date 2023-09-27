import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ukrainianNames = ["Ivan", "Maria", "Oleksiy", "Olena", "Dmytro", "Olha", "Andrii", "Nataliia", "Serhii", "Tetiana", "Pavlo", "Anna", "Mykhailo", "Kateryna", "Kostiantyn", "Svitlana", "Volodymyr", "Liudmyla", "Artem", "Iryna"]
        
        let game = Game(playerNames: ukrainianNames)
        let timerGame = TimerGame(game: game)
        timerGame.startGame()
        
        for name in ukrainianNames {
            let player = Player(name: name)
            game.players.append(player)
        }
        
        game.startGame()
        game.printPlayerScores()
    }
}
