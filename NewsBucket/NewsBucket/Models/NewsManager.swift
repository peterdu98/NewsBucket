//
//  NewsManager.swift
//  NewsBucket
//
//  Created by Peter Du on 14/4/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import Foundation

protocol NewsManagerDelegate {
    func didUpdateNews(_ newsManager: NewsManager, articleStore: [[String: String]])
}

class NewsManager {
    var platform: String
    
    var delegate: NewsManagerDelegate?
    
    init(_ platform: String) {
        self.platform = platform
    }
    
    func fetchData(with category: String, query text: String?) {
        
        let urlString = customiseURL(with: category, with: text)
        
        if let url = URL.init(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    return
                } else {
                    if let newsData = data  {
                        if let articleStore = self.parseJSON(newsData) {
                            var articles: [[String: String]] = []
                            
                            // Converting stored objects
                            if let store = articleStore as? TraditionalStore {
                                
                                let objects = store.articles
                                for obj in objects {
                                    if let title = obj.title, let author = obj.author, let description = obj.description, let date = obj.publishedAt, let sourceName = obj.source["name"] {
                                        let tempDict: [String: String] = [
                                            "title": title,
                                            "author": author,
                                            "description": description,
                                            "publishedAt": date,
                                            "source": sourceName ?? "Unknown"
                                        ]
                                        articles.append(tempDict)
                                    }
                                }
                            } else if let store = articleStore as? DeveloperStore {
                                let objects = store.hits
                                for obj in objects {
                                    if let title = obj.title, let author = obj.author, let date = obj.created_at, let url = obj.url {
                                        let tempDict: [String: String] = [
                                            "title": title,
                                            "author": author,
                                            "publishedAt": date,
                                            "url": url
                                        ]
                                        articles.append(tempDict)
                                    }
                                 }
                            }
                            self.delegate?.didUpdateNews(self, articleStore: articles)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    private func parseJSON(_ newsData: Data) -> Any? {
        let decoder = JSONDecoder()
        do {
            var decodedData: Any?
            
            if platform == K.Platform.trad {
                decodedData = try decoder.decode(TraditionalStore.self, from: newsData)
            } else if platform == K.Platform.dev {
                decodedData = try decoder.decode(DeveloperStore.self, from: newsData)
            }
            
            return decodedData
        } catch {
            return nil
        }
    }
    
    private func customiseURL(with category: String, with query: String?) -> String {
        var urlString: String = "Unkown"
        
        if platform == K.Platform.trad {
            urlString = K.URLManager.traditionalDomain
            urlString += "&category=\(category)&pageSize=100"
            
        } else if platform == K.Platform.dev {
            urlString = K.URLManager.developerDomain
            let safeQuery = query ?? ""
            
            if category == "Jobs" {
                urlString += "search_by_date?tags=job&hitsPerPage=30&query=\(safeQuery)"
            } else {
                urlString += "search?tags=front_page&hitsPerPage=30&query=\(safeQuery)"
            }
        }
        
        return urlString
    }
}
