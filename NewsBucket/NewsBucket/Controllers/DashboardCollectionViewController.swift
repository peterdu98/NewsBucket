//
//  DashboardCollectionViewController.swift
//  NewsBucket
//
//  Created by Peter Du on 24/5/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class DashboardCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let chartLabels = K.DashboardManager.labels
    private var categories: [[String]] = [[], []]
    private var numNews: [[Double]] = [[], []]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(ChartCell.self, forCellWithReuseIdentifier: K.CellManager.dashboardCellIdentifier)
        
        loadCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    
    //MARK: - Button Actions
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - DataSource Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chartLabels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CellManager.dashboardCellIdentifier, for: indexPath) as! ChartCell
        
        cell.chartLabel = chartLabels[indexPath.row]
        cell.categories = categories[indexPath.row]
        cell.numNews = numNews[indexPath.row]
        
        return cell
    }
    
    //MARK: - Layout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}

//MARK: - Database
extension DashboardCollectionViewController {
    func loadCategory () {
        let request: NSFetchRequest<NewsCategory> = NewsCategory.fetchRequest()
        var devCate: [String] = []
        var devStat: [Double] = []
        var tradStat: [Double] = []
        var tradCate: [String] = []
        
        do {
            let result = try context.fetch(request)
            
            for item in result {
                if let platformName = item.parentPlatform?.name {
                    if platformName == K.Platform.dev {
                        if item.count != 0 {
                            devCate.append(item.name!)
                            devStat.append(Double(item.count))
                        }
                    } else if platformName == K.Platform.trad {
                        if item.count != 0 {
                            tradCate.append(item.name!)
                            tradStat.append(Double(item.count))
                        }
                    }
                }
            }
            categories = [devCate, tradCate]
            numNews = [devStat, tradStat]
            
            collectionView.reloadData()
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
}
