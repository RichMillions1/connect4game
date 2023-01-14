//
//  GameViewController.swift
//  Connect4
//
//  Created by Weimin Sun on 05/12/2022.
//

import UIKit
import Alpha0Connect4

class GameViewController: UIViewController {
    // Game session
    private var gameSession = GameSession()
    // Set  bot parameters
    private var botColor: GameSession.DiscColor = .red // bot colour
    private var isBotFirst = false // Whether machine priority
    
    private var canPlay: Bool = true
    
    lazy var topView: UIView = {
        let topView = UIView()
        topView.backgroundColor = .white
        return topView
    }()
    
    var discsColumnViewList = [DiscsColumnView]() // The discs in each column are added to a separate view to prevent gravity discs from rolling directly into other columns instead of being aligned vertically.
    
    var discsViewList = [DiscsView]() //Customised discs
    
    //Skeleton game board
    lazy var gameBoard: UIView = {
        let gameBoard = UIView()
        gameBoard.backgroundColor = UIColor.systemBlue
        return gameBoard
    }()
    
    //Results
    @IBOutlet weak var resultLab: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        setGameBoard()
        
    }
    
    func setupUI()  {
        //The entire upper play area
        self.view.addSubview(self.topView)
        topView.frame = CGRect(x: 0, y: 0, width: KscreenW, height: KscreenH * 0.7)
        for i in 0..<7 {
            //Seven columns in total
            let discsColumnView = DiscsColumnView(frame: CGRect(x: discsWH * Double(i), y: 0, width: discsWH, height: topView.frame.height))
            //discsColumnView.backgroundColor = UIColor.randomColor
            discsColumnViewList.append(discsColumnView)
            topView.addSubview(discsColumnView);
        }
        
        //Setting up the game board
        let gameBoardH = KscreenW * 6/7.0
        self.topView.addSubview(self.gameBoard)
        gameBoard.frame = CGRect(x: 0, y: self.topView.frame.size.height - gameBoardH, width: KscreenW, height: gameBoardH)
        
        resultLab.text = ""
        
        
    }
    
    
    
    //MARK: Setting up the game board skeleton
    func setGameBoard() {
        //7 per row
        let maskPath = UIBezierPath(rect: self.gameBoard.bounds)
        //Create 42 holes
        for i in 0..<42 {
            let rect = CGRect(x: 5 + discsWH * Double((i%7)), y: 5 + discsWH * Double(i/7), width: holeWH, height: holeWH)
            
            let holePath = UIBezierPath(roundedRect: rect,cornerRadius: discsWH/2.0)
            maskPath.append(holePath)
        }
        let mask = CAShapeLayer()
        mask.fillRule = .evenOdd
        mask.path = maskPath.cgPath
        self.gameBoard.layer.mask = mask
    }
    
    
    // Start game session with random bot parameter
    private func newGameSession() {
        // Print game layout
        print("CONNECT4 \(gameSession.boardLayout.rows) rows by \(gameSession.boardLayout.columns) columns")
        
        // Start game, resuming with some discs
        // set initialMoves to [(Int, Int)]() to start with clear board
        //let initialMoves = [(row: 1, column: 4), (row: 2, column: 4)]
        
        //Start the game
        self.gameSession.startGame(delegate: self, botPlays: self.botColor, first: self.isBotFirst,initialPositions: [(Int, Int)]())
    }
    
    
    
    //MARK: - Event response
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // The bot is playing, or it hasn't started yet, or it's over
        if self.canPlay == false {
            return
        }
        // ensure click on the game board to drop the ball
        if let touche = touches.first,
           let result =  touche.view?.isDescendant(of: self.gameBoard),
           result == true{
            //Click on the game board
            let point = touche.location(in: self.gameBoard)
            self.calculationPosition(point: point)
        }
        // dropBubble()
    }
    
    
    //Calculate which column to drop in
    func calculationPosition(point: CGPoint) {
        var column:Int = -1
        //Circulation
        repeat{
            column += 1
        } while !((point.x >= discsWH * Double(column)) && (point.x <= discsWH * Double(column+1)))
        
        column += 1
        //Tell the bot which column I have placed it in
        if gameSession.isValidMove(column) {
            // Drop disc
            gameSession.dropDiscAt(column)
        }
        
    }
    
    //MARK: After the drop show the disc
    private func showDropDiscs(location:(row: Int, column: Int), color: DiscColor ,index: Int) {
        // Remove this column
        let discsColumnView = discsColumnViewList[location.column-1]
        var frame = CGRect()
        frame.origin = CGPoint.zero
        frame.size = Constants.bubbleSize
        var discsView: DiscsView!
        if color == .yellow {
            //Create a yellow ball, record the number of the ball and the column
            discsView = DiscsView(frame: frame, borderColor: yellowColor2, contentColor: yellowColor1,text: "\(index)", column: location.column)
        } else {
            discsView = DiscsView(frame: frame, borderColor: redColor2, contentColor: redColor1,text: "\(index)",  column: location.column)
        }
        self.discsViewList.append(discsView)
        discsColumnView.addSubview(discsView)
        //Add gravity drop animation
        discsColumnViewList[location.column-1].addAnimationItem(discsView: discsView)
    }
    
    //Choose who goes first
    func firstChoice() {
        showAlertVC(message: "Who plays first?") { index in
            // Copy random colours to the bot
            self.botColor = Int.random(in: 0..<2) == 0 ? .red : .yellow
            if index == 2 {
                self.isBotFirst = true
                self.resultLab.text = "Bot (\(self.botColor == .red ? "Red" : "Yellow")) Turn"
            }else {
                self.isBotFirst = false
                self.resultLab.text = "Your (\(self.botColor == .red ? "Yellow" : "Red")) Turn"
            }
            
            self.newGameSession()
        }
    }
    
    @IBAction func reStartGame(_ sender: UIBarButtonItem) {
        firstChoice()
    }
    
}



extension GameViewController: GameSessionProtocol
{
    // GameSessionProtocol update for game state changes
    func stateChanged(_ gameSession: GameSession, state: SessionState, for playerTurn: DiscColor, textLog: String) {
        // Handle state transition
        print(state)
        switch state
        {
            // Inital state
        case .cleared:
            // Enable button if player turn is user
            let isUserTurn = (playerTurn != botColor)
            canPlay = isUserTurn
            for (_, discsView) in self.discsViewList.enumerated() {
                let discsColumnView = self.discsColumnViewList[discsView.column-1]
                discsColumnView.removeAnimationItem(discsView: discsView)
                discsView.removeFromSuperview()
            }
            self.discsViewList.removeAll()
            // Player evaluating position to play
        case .thinking(_):
            // Disable button while thinking
            canPlay = false
            
            // Waiting for player to play
        case .idle(let color):
            // If player is bot, drop piece automatically
            // otherwise enable drop disc button
            if color == botColor {
                canPlay = false
                self.resultLab.text = "Bot (\(self.botColor == .red ? "Red" : "Yellow")) Turn"
                gameSession.dropDisc()
            } else {
                canPlay = true
                self.resultLab.text = "Your (\(self.botColor == .red ? "Yellow" : "Red")) Turn"
                print("waiting for \(color)")
            }
            
            // End of game, update UI with game result, start new game
        case .ended(let outcome):
            // Disable button
            canPlay = false
            
            // Display game result
            var gameResult: String
            switch outcome {
            case botColor:
                gameResult = "Bot (\(botColor)) wins!"
            case !botColor:
                gameResult = "User (\(!botColor)) wins!"
            default:
                gameResult = "Draw!"
            }
            resultLab.text =  gameResult
            self.canPlay = false
            showAlertVC(title: "", message: "Game over \n \(gameResult)")

            
            // Save to core date
            let moc = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
            _ = CoreDataSession.save(botPlays: botColor, first: isBotFirst, layout: gameSession.boardLayout,
                                     positions: gameSession.playerPositions, winningPositions: gameSession.winningPositions,
                                     in: moc)
            
            
            
            
        @unknown default:
            break
        }
    }
    
    
    // GameSessionProtocol notifying of the result of a player action
    // textLog provides some string visualization of the game board for debug purposes
    func didDropDisc(_ gameSession: GameSession, color: DiscColor, at location: (row: Int, column: Int), index: Int, textLog: String) {
        print("\(color) drops at \(location)")
        self.showDropDiscs(location: location, color: color, index: index)
        //self.gameLabel.text = textLog
    }
    
    
    // GameSessionProtocol notification of next player to play
    func turnToPlay(_ gameSession: GameSession, color: DiscColor) {
        print("\(color) turn")
    }
    
    
    // GameSessionProtocol notification of end of game
    func didEnd(_ gameSession: GameSession, color: DiscColor?, winningActions: [(row: Int, column: Int)]) {
        // Display winning disc positions
        print(winningActions.map({"\($0)"}).joined(separator: " "))
    }
    
}





