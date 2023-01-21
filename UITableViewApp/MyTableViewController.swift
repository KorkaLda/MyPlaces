//
//  MyTableViewController.swift
//  UITableViewApp
//
//  Created by Vladimir on 21.01.2023.
//

import UIKit

class MyTableViewController: UITableViewController {

    
    let restaurantNames = [
    "Craft Шаурма", "Кушай Мясо", "Kitchen", "Speak Easy", "БИГ ПИГ", "Вкусно и Точка", "Бочка", "Staff bar"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurantNames.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

//        var content = cell.defaultContentConfiguration()
//        content.text =
        cell.imageView?.image = UIImage(named: restaurantNames[indexPath.row])
        cell.textLabel?.text = restaurantNames[indexPath.row]

        cell.imageView?.layer.cornerRadius = cell.frame.size.height/2
        cell.imageView?.clipsToBounds = true
//        cell.backgroundColor = .green
//        cell.contentConfiguration = content
        
        
        return cell
    }
    
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
