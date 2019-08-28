//
//  ImageTableViewCell.swift
//  ImageSearch
//
//  Created by user on 26/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var picture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func modifyCell(image: UIImage) {
        self.picture.image = image
    }
}
