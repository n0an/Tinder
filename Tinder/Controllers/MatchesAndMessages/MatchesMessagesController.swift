//
//  MatchesMessagesController.swift
//  Tinder
//
//  Created by nag on 04.11.2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit
import LBTATools

class MatchesMessagesController: UICollectionViewController {
    
    let customNavBar: UIView = {
        let navBar = UIView(backgroundColor: .white)
        
        let iconImageView = UIImageView(image: #imageLiteral(resourceName: "top_messages_icon").withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        iconImageView.tintColor = #colorLiteral(red: 0.9860271811, green: 0.3476872146, blue: 0.4476813674, alpha: 1)
        let messagesLabel = UILabel(text: "Messages", font: .boldSystemFont(ofSize: 20), textColor: #colorLiteral(red: 0.9860271811, green: 0.3476872146, blue: 0.4476813674, alpha: 1), textAlignment: .center)
        let feedLabel = UILabel(text: "Feed", font: .boldSystemFont(ofSize: 20), textColor: .gray, textAlignment: .center)
        
        navBar.setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        
        navBar.stack(iconImageView.withHeight(44),
                     navBar.hstack(messagesLabel, feedLabel, distribution: .fillEqually)).padTop(10)
        
        
        
        return navBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
    }
    
}
