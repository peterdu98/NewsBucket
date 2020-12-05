//
//  ViewController.swift
//  NewsBucket
//
//  Created by Peter Du on 14/4/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit

class SummaryNewsViewController: UITableViewController, CAAnimationDelegate {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let connectivity = (UIApplication.shared.delegate as! AppDelegate).connectivity
    
    var articles: [[String: String]] = []
    var newsManager: NewsManager!
    var currentRow = 0
    
    var selectedPlatform: String? {
        didSet {
            newsManager = NewsManager(self.selectedPlatform!)
        }
    }
    var selectedCategory: NewsCategory? {
        didSet {
            newsManager.fetchData(with: self.selectedCategory!.name!, query: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSearchBar()
    
        newsManager.delegate = self
        searchBar.delegate = self

        // register the customised cell
        tableView.register(UINib(nibName: K.CellManager.summaryCell, bundle: nil),
                                 forCellReuseIdentifier: K.CellManager.summaryCellIdentifier)
        
        spinner.startAnimating()
        
        // Callback for Internet hooks
        connectivity.whenDisconnected = { connectivity in
            let alertAction = UIAlertAction(title: "Go back", style: .default) { UIAlertAction in
                self.navigationController?.popViewController(animated: true)
            }
            let alert = Utils.layoutAlert(with: "Your device has no Internet connection.", handle: alertAction)
            self.present(alert, animated: true)
        }
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
    
    //MARK: - Layout SearchBar
    private func layoutSearchBar() {
        if let safePlatform = selectedPlatform {
            if safePlatform == K.Platform.trad {
                searchBar.isHidden = true
                searchBar.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            }
        }
    }
}

//MARK: - NewsManager Delegate
extension SummaryNewsViewController: NewsManagerDelegate {
    func didUpdateNews(_ newsManager: NewsManager, articleStore: [[String: String]]) {
        DispatchQueue.main.async {
            self.articles = articleStore
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
            self.tableView.reloadData()
        }
    }
}

//MARK: - TableView Delegate, DataSource
extension SummaryNewsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Update current row index
        currentRow = indexPath.row

        // Perform Segue
        let identifier = (selectedPlatform! == K.Platform.trad) ? K.SegueManager.summayToDetails : K.SegueManager.summaryToWeb
        performSegue(withIdentifier: identifier, sender: self)

        // Animation for row deselection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellManager.summaryCellIdentifier, for: indexPath) as! SummaryCell
        let article = articles[indexPath.row]

    
        if let articleTitle = article["title"] {
            cell.titleLabel.text = articleTitle
        }
    
        if let date = article["publishedAt"] {
            let formattedDate = Utils.reformatDate(from: date, with: selectedPlatform!)
            cell.dateLabel.text = "Date: \(formattedDate)"
        } else {
            cell.dateLabel.text = "Unknown"
        }
    
        if selectedPlatform! == K.Platform.trad {
            cell.sourceLabel.text = "Published by: \n \(article["source"] ?? "Unknown")"
        } else if selectedPlatform! == K.Platform.dev {
            cell.sourceLabel.text = "Published by: \n \(article["author"] ?? "Unkown")"
        }
        
        return cell
    }
}

//MARK: - Prepare for Segue to DetailNews
extension SummaryNewsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueManager.summayToDetails {
            if let destination = segue.destination as? DetailNewsViewController {
                let article = articles[currentRow]
                
                if let date = article["publishedAt"] {
                    let formattedDate = Utils.reformatDate(from: date, with: selectedPlatform!)
                    destination.newsDate = formattedDate
                } else {
                    destination.newsDate = "Unknown"
                }

                destination.newsTitle = Utils.htmlToString(article["title"] ?? "Unknown")
                destination.newsAuthor = article["author"] ?? "Unknown"
                destination.newsDescription = Utils.htmlToString(article["description"] ?? "Unknown")
                destination.newsSource = article["source"] ?? "Unknown"
                destination.selectedCategory = selectedCategory
                destination.selectedPlatform = selectedPlatform
            }
        } else if segue.identifier == K.SegueManager.summaryToWeb {
            if let destination = segue.destination as? BrowserViewController {
                let article = articles[currentRow]
                
                destination.newsTitle = article["title"]
                destination.newsAuthor = article["author"]
                destination.urlString = article["url"]
                destination.selectedCategory = selectedCategory
                destination.selectedPlatform = selectedPlatform
                
                if let date = article["publishedAt"] {
                    let formattedDate = Utils.reformatDate(from: date, with: selectedPlatform!)
                    destination.newsDate = formattedDate
                } else {
                    destination.newsDate = "Unknown"
                }
            }
        }
    }
}

//MARK: - SearchBar Delegate
extension SummaryNewsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        articles.removeAll()
        newsManager.fetchData(with: self.selectedCategory!.name!, query: searchBar.text!)
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            articles.removeAll()
            newsManager.fetchData(with: self.selectedCategory!.name!, query: nil)
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
