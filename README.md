# NewsBucket

A news bucket contains the most recent news from different countries around the world. Not only that, developers can use it for browsing technical news and jobs.

## Demo 


<p float="left" align="center">
  <img src="https://github.com/peterdu98/NewsBucket/blob/main/screenshots/news-1.png" width="200" />
  <img src="https://github.com/peterdu98/NewsBucket/blob/main/screenshots/news-2.png" width="200" />
  <img src="https://github.com/peterdu98/NewsBucket/blob/main/screenshots/news-3.png" width="200" /> 
  <img src="https://github.com/peterdu98/NewsBucket/blob/main/screenshots/news-4.png" width="200" /> 
</p>

<p float="left" align="center">
  <img src="https://github.com/peterdu98/NewsBucket/blob/main/screenshots/news-5.png" width="200" /> 
  <img src="https://github.com/peterdu98/NewsBucket/blob/main/screenshots/news-6.png" width="200" /> 
  <img src="https://github.com/peterdu98/NewsBucket/blob/main/screenshots/news-7.png" width="200" /> 
  <img src="https://github.com/peterdu98/NewsBucket/blob/main/screenshots/news-8.png" width="200" /> 
</p>

## Technologies
1. Swift with UIKit for UI/UX
2. Model-View-Controller (MVC) design pattern for app's architecture
3. Core Data for storing data locally
4. An embedded website in the app with WebKit
5. Managing Internet connection with the Connectivity library
6. Performing analytics with the Charts library
7. Custom modal view for switching between online and offline modes
8. Spinner with animation for informing the loading progress.

## APIs
1. [NewsAPI](https://newsapi.org/)
2. [Hacker News](https://hn.algolia.com/api/)

## Requirements
1. All necessary dependencies
```
cd NewsBucket
pod install
```
2. The API key for NewsAPI
```
// Go to NewsAPI to generate the API key
// Open NewsBucket/NewsBucket/Constants.swift
// Edit the traditionalDomain with the generated API key
```
