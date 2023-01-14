//
//  HistoryDetailViewController.swift
//  Connect4
//
//  Created by apple on 05/12/2022.
//

import UIKit
import Alpha0Connect4

class HistoryDetailViewController: UIViewController {
    public var sessionItem: CoreDataSession!
    
    @IBOutlet weak var resultLab: UILabel!
    // Set  bot parameters
    private var botColor: DiscColor = .red// bot colour
    private var isBotFirst = false // Whether bot priority
    
    private var canPlay: Bool = true
    
    lazy var topView: UIView = {
        let topView = UIView()
        topView.backgroundColor = .white
        return topView
    }()
    var discsColumnViewList = [DiscsColumnView]()
    var discsViewList = [DiscsView]()
    lazy var gameBoard: UIView = {
        let gameBoard = UIView()
        gameBoard.backgroundColor = UIColor.systemBlue
        return gameBoard
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        setGameBoard()
        isBotFirst = sessionItem.botIsFirst
        if let winningColor = sessionItem.winningColor {
            
            self.botColor = DiscColor(rawValue: Int(sessionItem.botColor)) ?? .red
            let result = self.botColor == winningColor ? "Bot (\(winningColor == .yellow ? "yellow" : "red")) wins" : "User (\(winningColor == .yellow ? "yellow" : "red" )) wins"
            resultLab.text = result
        }
        
        self.animationShowDetail()
        
    }
    
    func setupUI()  {
        self.view.addSubview(self.topView)
        topView.frame = CGRect(x: 0, y: 0, width: KscreenW, height: KscreenH * 0.7)
        
        for i in 0..<7 {
            let discsColumnView = DiscsColumnView(frame: CGRect(x: discsWH * Double(i), y: 0, width: discsWH, height: topView.frame.height))
            //discsColumnView.backgroundColor = UIColor.randomColor
            discsColumnViewList.append(discsColumnView)
            topView.addSubview(discsColumnView);
        }
        
        let gameBoardH = KscreenW * 6/7.0
        self.topView.addSubview(self.gameBoard)
        gameBoard.frame = CGRect(x: 0, y: self.topView.frame.size.height - gameBoardH, width: KscreenW, height: gameBoardH)
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
    
    func animationShowDetail()  {
        guard var discs = sessionItem.discs?.objectEnumerator().allObjects as? [CoreDataDisc]  else{
            return
        }
        discs = discs.sorted(by: {$0.index < $1.index})
        var firstColor: DiscColor!
        var secondColor: DiscColor!
        if isBotFirst {
            firstColor = botColor
        } else {
            firstColor = botColor == .red ? .yellow : .red
        }
        
        secondColor = firstColor == .red ? .yellow : .red
        //Timer loop display
        var index = 0
        let timer = Timer(timeInterval: 0.3, repeats: true) { timer in
            if index >= discs.count {
                timer.invalidate()
                
                return
            }
            let item = discs[index]
            let color = index%2 == 0 ? firstColor : secondColor
            self.showDropDiscs(location: (Int(item.row),Int(item.column)), color: color!, index: Int(item.index))
            index += 1
        }
        timer.fire()
        RunLoop.current.add(timer, forMode: .common)
    }
    
    //MARK: After the drop show the disc
    private func showDropDiscs(location:(row: Int, column: Int), color: DiscColor ,index: Int) {
        let discsColumnView = discsColumnViewList[location.column-1]
        var frame = CGRect()
        frame.origin = CGPoint.zero
        frame.size = Constants.bubbleSize
        var discsView: DiscsView!
        if color == .yellow {
            discsView = DiscsView(frame: frame, borderColor: UIColor.init(0xB8860BFF), contentColor: UIColor.init(0xFFFF00FF),text: "\(index)",column: location.column)
        } else {
            discsView = DiscsView(frame: frame, borderColor: UIColor.init(0xCD2626FF), contentColor: UIColor.init(0xFF0000FF),text: "\(index)",column: location.column)
        }
        self.discsViewList.append(discsView)
        discsColumnView.addSubview(discsView)
        discsColumnView.addAnimationItem(discsView: discsView)
        
    }
    
    
    
    @IBAction func reStartGame(_ sender: UIBarButtonItem) {
        //Remove gravity ball effect
        for (_, discsView) in self.discsViewList.enumerated() {
            let discsColumnView = self.discsColumnViewList[discsView.column-1]
            discsColumnView.removeAnimationItem(discsView: discsView)
            discsView.removeFromSuperview()
        }
        //Delete the array
        self.discsViewList.removeAll()
        //Animation re-add
        animationShowDetail()
    }
    
}





