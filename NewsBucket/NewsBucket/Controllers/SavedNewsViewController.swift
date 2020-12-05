//
//  SavedNewsList.swift
//  NewsBucket
//
//  Created by Peter Du on 22/4/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit
import CoreData
//import Connectivity

class SavedNewsViewController: UITableViewController {
        
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let connectivity = (UIApplication.shared.delegate as! AppDelegate).connectivity
    var selectedPlatform: String?
    var selectedCategory: NewsCategory? {
        didSet {
            loadSavedNews()
        }
    }
    
    var listNews = [SavedNews]()
    var selectedMode: Int = 0
    var selectedRow = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register the customised cell
        tableView.register(UINib(nibName: K.CellManager.summaryCell, bundle: nil), forCellReuseIdentifier: K.CellManager.newsListCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        connectivity.startNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
        connectivity.stopNotifier()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UISegmentControl Actions
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        // 0 means read | 1 means delete
        selectedMode = sender.selectedSegmentIndex
        
        // Reload the table view
        if let visibleRows = tableView?.indexPathsForVisibleRows {
            tableView.reloadRows(at: visibleRows, with: .automatic)
        }
    }
    
    //MARK: - Seque prepartion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueManager.saveToDetails {
            if let destination = segue.destination as? DetailNewsViewController {
                let article = listNews[selectedRow]

                if let date = article.publishedAt {
                    destination.newsDate = date
                } else {
                    destination.newsDate = "Unknown"
                }

                destination.newsTitle = article.title ?? "Unknown"
                destination.newsAuthor = article.author ?? "Unknown"
                destination.newsDescription = article.desc ?? "Unknown"
                destination.newsSource = article.source ?? "Unknown"
                destination.selectedCategory = selectedCategory
            }
        } else if segue.identifier == K.SegueManager.saveToBrowser {
            if let destination = segue.destination as? BrowserViewController {
                let article = listNews[selectedRow]
                
                destination.newsTitle = article.title
                destination.urlString = article.url
                destination.selectedCategory = selectedCategory
            }
        }
    }
}

//MARK: - Table View Delegate, DataSourcce
extension SavedNewsViewController {
    //MARK: - DataSource Method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listNews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellManager.newsListCellIdentifier, for: indexPath) as! SummaryCell

        let article = listNews[indexPath.row]

        // Custom the summary cell
        cell.selectedMode = selectedMode
        if let articleTitle = article.title {
            cell.titleLabel.text = articleTitle
        }
    
        if let date = article.publishedAt {
            cell.dateLabel.text = "Date: \(date)"
        } else {
            cell.dateLabel.text = "Unknown"
        }
    
        if selectedPlatform! == K.Platform.trad {
            cell.sourceLabel.text = "Published by: \n \(article.source ?? "Unknown")"
        } else if selectedPlatform! == K.Platform.dev {
            cell.sourceLabel.text = "Published by: \n \(article.author ?? "Unkown")"
        }
        
        return cell
    }
    
    //MARK: - Data Delegate Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        
        if selectedMode == 0 {
            if selectedPlatform == K.Platform.trad {
                performSegue(withIdentifier: K.SegueManager.saveToDetails, sender: self)
            } else if selectedPlatform == K.Platform.dev {
                if connectivity.isConnected {
                    performSegue(withIdentifier: K.SegueManager.saveToBrowser, sender: self)
                } else {
                    let alert: UIAlertController = Utils.layoutAlert(with: "Your device has no Internet connection.")
                    self.present(alert, animated: true)
                }
            }
        } else {
            deleteNews(at: indexPath)
            tableView.reloadData()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Database interation
extension SavedNewsViewController {
    func loadSavedNews() {
        let request: NSFetchRequest<SavedNews> = SavedNews.fetchRequest()
        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@ ", selectedCategory!.name!)
        request.predicate = predicate
        
        do {
            listNews = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }

    func deleteNews(at indexPath: IndexPath) {
        // Delete From NSObject
        context.delete(listNews[indexPath.row])

        // Delete From current News list
        listNews.remove(at: indexPath.row)

        // Save deletion
        do {
            try context.save()
        } catch {
            print("Error when saving data \(error)")
        }
    }
}
