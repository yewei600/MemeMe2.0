//
//  MemeDetailViewController.swift
//  MemeMe2
//
//  Created by Eric Wei on 2017-01-10.
//  Copyright © 2017 EricWei. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    
    //MARK: Properties
    var meme: Meme!
    
    //MARk: Outlets
    @IBOutlet weak var memeImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.memeImageView!.image = meme.memeImage
    }
    
}
