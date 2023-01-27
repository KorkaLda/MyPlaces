//
//  MyTableViewController.swift
//  UITableViewApp
//
//  Created by Vladimir on 21.01.2023.
//

import UIKit
import RealmSwift

class MyTableViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool{
        guard let text = searchController.searchBar.text else{ return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
        
        //Настройка search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.layer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 300)
//        searchController.searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 300)
        navigationItem.searchController?.preferredContentSize = CGSize(width: 100, height: 100)
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if isFiltering{
             return filteredPlaces.count
         }
        return places.isEmpty ? 0 : places.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

         var place = Place()
         if isFiltering {
             place = filteredPlaces[indexPath.row]
         }else {
             place = places[indexPath.row]
         }

        cell.nameLabel.text = place.name
        cell.typeLabel.text = place.type
        cell.locationLabel.text = place.location
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.bounds.width/2
        cell.imageOfPlace.contentMode = .scaleToFill
        cell.imageOfPlace.clipsToBounds = true
        return cell
    }
    
    //MARK: -  Table view delegate

     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let place:Place
            if isFiltering {
                place = filteredPlaces[indexPath.row]
            }else {
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
        
    }
    
    
    @IBAction func unwindSegue(_segue: UIStoryboardSegue){
        guard let newPlaceVC = _segue.source as? NewPlaceViewController else {return}
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        ascendingSorting.toggle()
        if ascendingSorting{
            reversedSortingButton.image = UIImage(systemName: "arrow.up.arrow.down.square.fill")
        }else{
            reversedSortingButton.image = UIImage(systemName: "arrow.up.arrow.down")
        }
        sorting()
    }
    
    private func sorting(){
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        }else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
    
}
extension MyTableViewController:UISearchResultsUpdating {
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText:String){
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText,searchText)
        tableView.reloadData()
    }
    
}
