//
//  CommentCell.swift
//  RangeComm
//
//  Created by David Ganshorn on 11/24/15.
//  Copyright © 2015 Christoph Mueller. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet var commentLabel: UILabel!
    
    @IBOutlet var createdAtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
