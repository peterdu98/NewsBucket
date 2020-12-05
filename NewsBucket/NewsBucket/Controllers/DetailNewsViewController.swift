//
//  DetailNews.swift
//  NewsBucket
//
//  Created by Peter Du on 15/4/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit
import CoreData

class DetailNewsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var staticDescLabel: UILabel!
    @IBOutlet weak var savedButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var newsTitle: String = "Unknown"
    var newsAuthor: String = "Unknown"
    var newsDate: String = "Unknown"
    var newsSource: String = "Unknown"
    var newsDescription: String = "Unknown"
    var isSaved: Bool = false
    
    var selectedPlatform: String?
    var selectedCategory: NewsCategory? {
        didSet {
            loadCategories()
        }
    }
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Parse passed data
        titleLabel.text = newsTitle
        authorLabel.text = "Published by \(newsAuthor)"
        dateLabel.text = "At: \(newsDate)"
        sourceLabel.text = "From: \(newsSource)"
        descriptionLabel.text = newsDescription
        
        if isSaved {
            savedButton.setTitle("Saved", for: .normal)
            savedButton.isUserInteractionEnabled = false
        } else {
            // Counting feature for live news only
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                self.countNewsToCategory()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
        timer?.invalidate()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func savedButtonPressed(_ sender: UIButton) {
        if !isSaved {
            saveNews()
        
            savedButton.setTitle("Saved", for: .normal)
            savedButton.isUserInteractionEnabled = false
        }
    }
    
}

//MARK: - Database Interaction
extension DetailNewsViewController {
    func loadCategories() {
        let request: NSFetchRequest<SavedNews> = SavedNews.fetchRequest()
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "parentCategory.name MATCHES %@ ", selectedCategory!.name!),
            NSPredicate(format: "title MATCHES %@", newsTitle)
        ])
        request.predicate = predicate
        
        do {
            let savedNews = try context.fetch(request)
            
            // Handle saved news
            if savedNews.count > 0 {
                isSaved = true
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func saveNews() {
        // Initalize the context
        let news = SavedNews(context: self.context)
        
        // Putting data
        news.title = newsTitle
        news.author = newsAuthor
        news.publishedAt = newsDate
        news.source = newsSource
        news.desc = newsDescription
        news.parentCategory = selectedCategory
        
        do {
            try context.save()
        } catch {
            print("Error when saving data \(error)")
        }
    }
    
    func countNewsToCategory() {
        // Intialize the context
        let request: NSFetchRequest<NewsCategory> = NewsCategory.fetchRequest()
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name MATCHES %@", selectedCategory!.name!),
            NSPredicate(format: "parentPlatform.name MATCHES %@", selectedPlatform!)
        ])
        request.predicate = predicate
        do {
            let category = try context.fetch(request)
            
            // Assume that there is only 1 category in 1 platform
            if category.count == 1 {
                let count = category[0].count + 1
                category[0].setValue(count, forKey: "count")
                do {
                    try context.save()
                } catch {
                    print("Error when saving data for counting \(error)")
                }
            }
        } catch {
            print("Error fetching data from category \(error)")
        }
    }
}
