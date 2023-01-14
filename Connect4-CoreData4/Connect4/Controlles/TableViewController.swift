//
//  TableViewController.swift
//  Connect4
//
//  Created by COMP47390 on 22/01/2022.
//  Copyright © 2020 COMP47390. All rights reserved.
//

import UIKit
import CoreData
import Alpha0Connect4

// MARK: - NSFetchedResultsController

class TableViewController: UITableViewController
{
    var fetchedResultsController: NSFetchedResultsController<CoreDataSession>!
    var viewContext: NSManagedObjectContext?
    func initializeFetchedResultsController() {
        //Data acquisition of core data
        let request = NSFetchRequest(entityName: "CoreDataSession") as! NSFetchRequest<CoreDataSession>
        let discCountSort = NSSortDescriptor(key: "discCount", ascending: true)
        let logSort = NSSortDescriptor(key: "log", ascending: true)
        request.sortDescriptors = [discCountSort, logSort]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let viewContext = appDelegate.persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do { try fetchedResultsController.performFetch() }
        catch { fatalError("Failed to initialize FetchedResultsController: \(error)") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
    }
    
    @IBAction func clearAction(_ sender: Any) {
        showAlertVC(title: "Clear History", message: "This will remove all saved games") {
            //Traversal
            if let allItems = self.fetchedResultsController.fetchedObjects?.enumerated() {
                for (_,item) in allItems {
                    let moc = item.managedObjectContext
                    moc?.delete(item)
                    try? moc?.save()
                }
            }
        }
        
    }
    
    @IBAction func editAction(_ sender: Any) {
        self.tableView.isEditing = !self.tableView.isEditing
    }
}

// MARK: - Data Source

extension TableViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        
        // Set up the cell
        guard let sessionItem = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        //cell.textLabel?.text = sessionItem.log
        cell.contentView.backgroundColor = .white
        //cell.detailTextLabel?.text = "Draw"
        // Winning side colour
        if let color = sessionItem.winningColor {
            let botColor = DiscColor(rawValue: Int(sessionItem.botColor))
            cell.startLab.text = sessionItem.botIsFirst ? "Bot starts" : "User starts"
            cell.startLab.textColor = sessionItem.botIsFirst ? (botColor == .red ? redColor1 : yellowColor1) : (botColor == .red ? yellowColor1 : redColor1)
            if botColor == color {
                cell.winLab.text = "Bot wins!"
                
            }else {
                cell.winLab.text = "User wins!"
            }
            cell.winLab.textColor = color == .red ? redColor1 : yellowColor1
            
        }
        drawGameBoard(sessionItem: sessionItem, cell: cell)
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            showAlertVC(title: "Delete", message: "Are you sure remove it") {
                if let item = self.fetchedResultsController?.object(at: indexPath), let moc = item.managedObjectContext {
                    moc.delete(item)
                    try? moc.save()
                }
            }
            
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Drawing a game board
    func drawGameBoard(sessionItem: CoreDataSession,cell: HistoryTableViewCell)  {
        print(sessionItem.log)
        let gameBoardView = cell.gameBoardView!
        let maskShapeLayer = cell.maskShapeLayer
        //Since cells are reused, it is important to remove the last
        maskShapeLayer.removeFromSuperlayer()
        maskShapeLayer.frame = gameBoardView.bounds
        //Create 42 holes
        let itemW = (gameBoardView.bounds.width)/7.0
        let itemH = (gameBoardView.bounds.height)/6.0
        //Frame height and weight of the disc
        let discsW = itemW - 4
        let discsH = itemH - 4
        var subMaskShapeLayerList = [CAShapeLayer]()
        for i in 0..<42 {
            let subMaskShapeLayer = CAShapeLayer()
            let rect = CGRect(x: 2 + itemW * Double((i%7)), y: 2 + itemH * Double(i/7), width: discsW, height: discsH)
            let discsPath = UIBezierPath(roundedRect: rect,cornerRadius: discsW/2.0)
            subMaskShapeLayer.path = discsPath.cgPath
            //Set all to white first, then yellow or red as required
            subMaskShapeLayer.fillColor = UIColor.white.cgColor
            maskShapeLayer.addSublayer(subMaskShapeLayer)
            
            //Record to data, find it and set the colour below
            subMaskShapeLayerList.append(subMaskShapeLayer)
        }
        // Get disc position data
        if let discs = sessionItem.discs?.objectEnumerator().allObjects as? [CoreDataDisc]{
            //First player colour
            var firstColor: UIColor!
            //secound player colour
            var secondColor: UIColor!
            let botColor: DiscColor? = DiscColor(rawValue: Int(sessionItem.botColor))
            //bot first, bot colour is first colour
            if sessionItem.botIsFirst {
                firstColor = botColor == .red ? redColor1 : yellowColor1
                secondColor = botColor == .red ? yellowColor1 : redColor1
            } else {
                //Player's first hand, bot colour not first hand colour
                firstColor = botColor == .red ? yellowColor1 : redColor1
                secondColor = botColor == .red ? redColor1 : yellowColor1
            }
            for disc in discs {
                // 36
                //Reference conversion disc.row disc.column is from the bottom left corner, to convert to top left index
                let i = ((6 - disc.row) * 7 + disc.column) - 1
                if i < 42 {
                    let myColor =  disc.index%2 == 1 ? firstColor : secondColor
                    subMaskShapeLayerList[Int(i)].fillColor = myColor?.cgColor
                }
            }
        }
        
        
        gameBoardView.layer.addSublayer(maskShapeLayer)
        
        
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        
        tableView.endUpdates()
    }
    
}

extension TableViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailPage",
           let vc = segue.destination as? HistoryDetailViewController,
           let indexPath = self.tableView.indexPathForSelectedRow,
           let sessionItem = self.fetchedResultsController?.object(at: indexPath){
            // Set up the cell
            vc.hidesBottomBarWhenPushed = true
            vc.sessionItem = sessionItem
        }
    }
}
