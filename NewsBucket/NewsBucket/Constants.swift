//
//  Constants.swift
//  NewsBucket
//
//  Created by Peter Du on 14/4/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

struct K {
    struct SegueManager {
        static let introToCategory = "introToCategory"
        static let categoryToSummary = "categoryToSummary"
        static let summayToDetails = "summaryToDetails"
        static let summaryToWeb = "summaryToWeb"
        static let categoryToSave = "categoryToSave"
        static let saveToDetails = "saveToDetails"
        static let categoryToDashboard = "categoryToDashboard"
        static let saveToBrowser = "saveToBrowser"
    }
    
    struct CellManager {
        static let categoryCell = "CategoryCell"
        static let categoryCellIdentifier = "categoryReusableCell"
        static let summaryCellIdentifier = "summaryNewsReusableCell"
        static let newsListCellIdentifier = "newsListResuableCell"
        static let dashboardCellIdentifier = "dashboardCellIdentifier"
        
        static let summaryCell = "SummaryCell"
    }
    
    struct Platform {
        static let trad = "traditional"
        static let dev = "developer"
    }
    
    
    struct URLManager {
        static let traditionalDomain = "https://newsapi.org/v2/top-headlines?country=au&apiKey=YOUR_API_KEY"
        static let developerDomain = "http://hn.algolia.com/api/v1/"
    }
    
    struct DashboardManager {
        static let labels = ["Number of read news in a developer platform",
                             "Number of read news in a traditional platform"]
        
    }
    
}
