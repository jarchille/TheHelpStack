//
//  MessageTableViewCell.swift
//  TheHelpStack
//
//  Created by Jonathan Archille on 1/9/17.
//  Copyright © 2017 The Iron Yard. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

   let nameLabel = UILabel()
   let detailLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // configure titleLabel
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        nameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        nameLabel.numberOfLines = 0
        
        
        // configure authorLabel
        contentView.addSubview(detailLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        detailLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        detailLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        detailLabel.font = UIFont(name: "Avenir-Book", size: 12)
        detailLabel.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
