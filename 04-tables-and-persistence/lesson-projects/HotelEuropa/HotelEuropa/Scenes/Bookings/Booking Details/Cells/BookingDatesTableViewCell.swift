//
//  BookingDatesTableViewCell.swift
//  HotelEuropa
//
//  Created by Brian Sipple on 5/11/19.
//  Copyright © 2019 Brian Sipple. All rights reserved.
//

import UIKit

final class BookingDatesTableViewCell: UITableViewCell {
    @IBOutlet private weak var checkInDateLabel: UILabel!
    @IBOutlet private weak var checkInTimeLabel: UILabel!
    @IBOutlet private weak var checkOutDateLabel: UILabel!
    @IBOutlet private weak var checkOutTimeLabel: UILabel!
    @IBOutlet private weak var numberOfNightsLabel: UILabel!

    
    struct ViewModel {
        var checkInDate: Date
        var checkOutDate: Date
        var numberOfNights: Int
    }
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            configure(with: viewModel)
        }
    }
}


// MARK: - Lifecycle

extension BookingDatesTableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        numberOfNightsLabel.layer.masksToBounds = true
        numberOfNightsLabel.layer.cornerRadius = 6.0
    }
    
}



// MARK: - ViewModel Configuration

extension BookingDatesTableViewCell {
    
    private func configure(with viewModel: ViewModel) {
        checkInDateLabel.text = viewModel.formattedCheckInDate
        checkInTimeLabel.text = viewModel.formattedCheckInTime

        checkOutDateLabel.text = viewModel.formattedCheckOutDate
        checkOutTimeLabel.text = viewModel.formattedCheckOutTime
        
        numberOfNightsLabel.text = viewModel.numberOfNightsText
    }
    
}


// MARK: - ViewModel Computeds

extension BookingDatesTableViewCell.ViewModel {
    var displayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        
        return formatter
    }
    
    var displayTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        
        return formatter
    }
    
    
    var formattedCheckInDate: String {
        return displayDateFormatter.string(from: checkInDate)
    }
    
    var formattedCheckInTime: String {
        return displayTimeFormatter.string(from: checkInDate)
    }
    
    var formattedCheckOutDate: String {
        return displayDateFormatter.string(from: checkOutDate)
    }
    
    var formattedCheckOutTime: String {
        return displayTimeFormatter.string(from: checkOutDate)
    }
    
    var numberOfNightsText: String {
        return "\(numberOfNights) \(numberOfNights == 1 ? "Night" : "Nights")"
    }
}
