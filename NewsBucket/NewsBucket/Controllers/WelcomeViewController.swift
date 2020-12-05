//
//  WelcomeViewController.swift
//  NewsBucket
//
//  Created by Peter Du on 12/5/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit
import CoreData

class WelcomeViewController: UIViewController {

    @IBOutlet weak var traditionalNewsButton: UIButton!
    @IBOutlet weak var devNewsButton: UIButton!
    
    var platforms = [NewsPlatforms]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let connectivity = (UIApplication.shared.delegate as! AppDelegate).connectivity
    
    var newsChoice = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        traditionalNewsButton.layer.cornerRadius = 10
        devNewsButton.layer.cornerRadius = 10
        
        // Load data from CoreData
        loadPlatforms()
        
        // Write data if there is no data yet
        if platforms.count == 0 {
            saveDefaultData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.barTintColor = UIColor.systemYellow
        connectivity.startNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
        connectivity.stopNotifier()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender == traditionalNewsButton {
            newsChoice = K.Platform.trad
        } else {
            newsChoice = K.Platform.dev
        }
        
        performSegue(withIdentifier: K.SegueManager.introToCategory, sender: self)
    }
    
    //MARK: - Segue preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueManager.introToCategory {
            if let destination = segue.destination as? CategoryTableViewController {
                destination.newsChoice = (newsChoice == K.Platform.trad) ? platforms[0] : platforms[1]
                // Handle Internet connection
                if connectivity.isConnected {
                    destination.savedMode = false
                } else {
                    destination.savedMode = true
                }
            }
       }
    }
    
    //MARK: - Default Data
    func saveDefaultData() {
        let temp = ["traditional", "developer"]
        for name in temp {
            let newPlatform = NewsPlatforms(context: self.context)
            newPlatform.name = name
            platforms.append(newPlatform)
            savePlatform()
        }
    }
}

//MARK: - Database
extension WelcomeViewController {
    func savePlatform() {
        do {
            try context.save()
        } catch {
            print("Error saving platforms \(error)")
        }
    }
    
    func loadPlatforms() {
        let request: NSFetchRequest<NewsPlatforms> = NewsPlatforms.fetchRequest()
        
        do {
            platforms = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
}
