//
//  ModalView.swift
//  NewsBucket
//
//  Created by Peter Du on 24/5/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit

class ModalView: UIView {
    let popupView: UIView = {
        let customisedView = UIView()
        customisedView.backgroundColor = UIColor(white: 1, alpha: 0.7)
        customisedView.layer.cornerRadius = 20.0
        customisedView.translatesAutoresizingMaskIntoConstraints = false
        
        return customisedView
    }()
    
    let firstButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go to Saved News", for: .normal)
        button.setTitleColor(.yellow, for: .normal)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: .semibold)
        button.backgroundColor = .none
        button.translatesAutoresizingMaskIntoConstraints = false
    
        return button
    }()
    
    let secondButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go to Dashboard", for: .normal)
        button.setTitleColor(.yellow, for: .normal)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: .semibold)
        button.backgroundColor = .none
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var isInSave: Bool!
    
    // Default constructor
     override init(frame: CGRect) {
        super.init(frame: frame)
        layoutView()
        layoutPopupView()
     }
     
     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutView()
        layoutPopupView()
     }
    
    // Customised constructor
    init(frame: CGRect, isInSave: Bool) {
        super.init(frame: frame)
        self.isInSave = isInSave
        
        layoutView()
        layoutPopupView()
        layoutButtons()
    }

}

//MARK: - Layout Static View
extension ModalView {
    private func layoutView() {
        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
    }
    
    private func layoutPopupView() {
        self.addSubview(popupView)
        
        NSLayoutConstraint.activate([
            popupView.widthAnchor.constraint(equalToConstant: self.frame.width/1.5),
            popupView.heightAnchor.constraint(equalToConstant: self.frame.height/7),
            popupView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

//MARK: - Layout Button View
extension ModalView {
    private func layoutButtons() {
        // Modification for the first button
        if isInSave {
            firstButton.setTitle("Go to Live News", for: .normal)
        }
        
        popupView.addSubview(firstButton)
        popupView.addSubview(secondButton)
        
        // layout for the first button
         NSLayoutConstraint.activate([
             firstButton.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 10.0),
             firstButton.bottomAnchor.constraint(equalTo: secondButton.topAnchor, constant: -10.0),
             firstButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor),
             firstButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor)
         ])
        
        // layout for the second button
        NSLayoutConstraint.activate([
            secondButton.topAnchor.constraint(equalTo: firstButton.bottomAnchor, constant: 10.0),
            secondButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -10.0),
            secondButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor),
            secondButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor)
        ])
    }
}
