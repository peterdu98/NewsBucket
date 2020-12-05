//
//  CategoryTableViewController.swift
//  NewsBucket
//
//  Created by Peter Du on 12/5/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let connectivity = (UIApplication.shared.delegate as! AppDelegate).connectivity
    
    var categories = [NewsCategory]()
    var currentRow = 0
    var modalView: ModalView!
    var isModal: Bool = false
    var savedMode: Bool = false
    
    var newsChoice : NewsPlatforms? {
        didSet {
            loadCategories()

            if categories.count == 0 {
                saveDefaultData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.CellManager.categoryCell, bundle: nil), forCellReuseIdentifier: K.CellManager.categoryCellIdentifier)
        
        // Alert a user about the Internet connection
        if !connectivity.isConnected {
            let alert: UIAlertController = Utils.layoutAlert(with: "You're in a saved mode. Turn on the Internet to go live.")
            self.present(alert, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        connectivity.startNotifier()
        
        // Callback for Internet hooks
        handleConnection()
        
        if !connectivity.isConnected {
            savedMode = true
        }
        layoutNavbar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
        connectivity.stopNotifier()
    }
    
    //MARK: - Bar Item Button
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func barButtonPressed(_ sender: UIBarButtonItem) {
        if isModal {
            modalView.removeFromSuperview()
            barButton.image = UIImage(named: "menu")
            tableView.isScrollEnabled = true
        } else {
            layoutModalView()
            barButton.image = UIImage(named: "X.filled")
            tableView.isScrollEnabled = false
        }
        isModal = !isModal
    }
    
    //MARK: - Popup Modal Layout
    private func layoutModalView() {
        modalView = ModalView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height), isInSave: savedMode)
        modalView.firstButton.addTarget(self, action: #selector(firstModalButtonTouchUp(_:)), for: .touchUpInside)
        modalView.secondButton.addTarget(self, action: #selector(secondModalButtonTouchUp(_:)), for: .touchUpInside)
        
        view.addSubview(modalView)
        
        NSLayoutConstraint.activate([
            modalView.widthAnchor.constraint(equalToConstant: view.frame.width),
            modalView.heightAnchor.constraint(equalToConstant: view.frame.height),
            modalView.topAnchor.constraint(equalTo: view.topAnchor),
            modalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    @objc private func firstModalButtonTouchUp(_ sender: UIButton) {
        // Alert a user about the Internet connection
        if !connectivity.isConnected && savedMode {
            let alert: UIAlertController = Utils.layoutAlert(with: "Sorry, this feature is only available with Internet connection.")
            self.present(alert, animated: true)
        } else {
            // Change saved mode
            savedMode = !savedMode
            
            // Refresh the modal
            modalView.removeFromSuperview()
            isModal = false
            barButton.image = UIImage(named: "menu")
            
            // Change navigation color
            layoutNavbar()
        }
    }
    
    @objc private func secondModalButtonTouchUp(_ sender: UIButton) {
        performSegue(withIdentifier: K.SegueManager.categoryToDashboard, sender: self)
    }

    private func layoutNavbar() {
        if savedMode {
              UIView.animate(withDuration: 0.3, animations: {
                  self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 0.9451, blue: 0.7373, alpha: 1.0)
                  self.navigationController?.navigationBar.layoutIfNeeded()
              })
          } else {
              UIView.animate(withDuration: 0.3, animations: {
                  self.navigationController?.navigationBar.barTintColor = UIColor.systemYellow
                  self.navigationController?.navigationBar.layoutIfNeeded()
              })
          }
    }
    
    //MARK: - Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueManager.categoryToSummary || segue.identifier == K.SegueManager.categoryToSave {
            if let destination = segue.destination as? SummaryNewsViewController {
                destination.selectedPlatform = newsChoice?.name
                destination.selectedCategory = categories[currentRow]
            } else if let destination = segue.destination as? SavedNewsViewController {
                destination.selectedPlatform = newsChoice?.name
                destination.selectedCategory = categories[currentRow]
            }
        }
    }
    
}

//MARK: - UITablView Delegate, Datascource
extension CategoryTableViewController {
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellManager.categoryCellIdentifier, for: indexPath) as! CategoryCell
        
        let name = categories[indexPath.row].name!
        
        cell.categoryImage.image = UIImage(named: name.lowercased())
        cell.categoryLabel.text = name
        
        return cell
    }
    
    //MARK: - Data Delegate Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentRow = indexPath.row
        
        if savedMode {
            performSegue(withIdentifier: K.SegueManager.categoryToSave, sender: self)
        } else {
            if connectivity.isConnected {
                performSegue(withIdentifier: K.SegueManager.categoryToSummary, sender: self)
            } else {
                let alert = Utils.layoutAlert(with: "Turn on Internet connection to read live news.")
                self.present(alert, animated: true)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Database
extension CategoryTableViewController {
    //MARK: - Default data
    func saveDefaultData() {
        var temp: [String]
        let choice = newsChoice!.name!

        if choice == K.Platform.dev {
            temp = ["Development", "Jobs"]
        } else {
            temp = ["Business", "General", "Health", "Sports"]
        }
        
        for name in temp {
            let newCategory = NewsCategory(context: self.context)
            newCategory.name = name
            newCategory.count = 0
            newCategory.parentPlatform = newsChoice!
            
            categories.append(newCategory)
            saveCategories()
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - Save to database
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving categories \(error)")
        }
    }
    
    func loadCategories() {
        let request: NSFetchRequest<NewsCategory> = NewsCategory.fetchRequest()
        let predicate = NSPredicate(format: "parentPlatform.name MATCHES %@", newsChoice!.name!)
        request.predicate = predicate
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
}

//MARK: - Internet Handler
extension CategoryTableViewController {
    private func handleConnection() {
        connectivity.whenConnected = { connectivity in
            self.savedMode = false
            self.layoutNavbar()
        }
        connectivity.whenDisconnected = { connectivity in
            self.savedMode = true
            self.layoutNavbar()
        }
    }
}
