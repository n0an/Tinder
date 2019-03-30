//
//  PhotoController.swift
//  Tinder
//
//  Created by nag on 30/03/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit

class PhotoController: UIViewController {
    
    var imageView = UIImageView()
    
    init(imageUrlString: String) {
        if let url = URL(string: imageUrlString) {
            imageView.sd_setImage(with: url)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
}
