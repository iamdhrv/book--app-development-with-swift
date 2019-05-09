//
//  CreateBookingViewController.swift
//  HotelEuropa
//
//  Created by Brian Sipple on 5/7/19.
//  Copyright © 2019 Brian Sipple. All rights reserved.
//

import UIKit

class CreateBookingViewController: UITableViewController {
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    
    @IBOutlet private weak var checkInDateCell: UITableViewCell!
    @IBOutlet private weak var checkInDatePickerCell: UITableViewCell!
    @IBOutlet private weak var checkOutDateCell: UITableViewCell!
    @IBOutlet private weak var checkOutDatePickerCell: UITableViewCell!
    
    @IBOutlet private weak var checkInDateValueLabel: UILabel!
    @IBOutlet private weak var checkInDatePicker: UIDatePicker!
    @IBOutlet private weak var checkOutDateValueLabel: UILabel!
    @IBOutlet private weak var checkOutDatePicker: UIDatePicker!
    
    
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    
    var modelController: CreateBookingModelController!
    var booking: Booking?

    private lazy var checkInDateIndexPath = IndexPath(row: 0, section: 1)
    private lazy var checkInDatePickerIndexPath = IndexPath(row: 1, section: 1)
    
    private lazy var checkOutDateIndexPath = IndexPath(row: 2, section: 1)
    private lazy var checkOutDatePickerIndexPath = IndexPath(row: 3, section: 1)
    
    private lazy var visibleDatePickerHeight = CGFloat(212)
    
    private var isCheckInPickerVisible = false {
        didSet {
            tableView.beginUpdates()
            checkInDatePicker.isHidden = !isCheckInPickerVisible
            checkOutDatePicker.isHidden = isCheckInPickerVisible
            tableView.endUpdates()
        }
    }
    
    private var isCheckOutPickerVisible = false {
        didSet {
            tableView.beginUpdates()
            checkOutDatePicker.isHidden = !isCheckOutPickerVisible
            checkInDatePicker.isHidden = isCheckOutPickerVisible
            tableView.endUpdates()
        }
    }
}


// MARK: - Computed Properties

extension CreateBookingViewController {
    
    var bookingChanges: CreateBookingModelController.Changes {
        return (
            firstName: firstNameTextField.text ?? "",
            lastName: lastNameTextField.text ?? "",
            emailAddress: emailTextField.text ?? "",
            checkInDate: checkInDatePicker.date,
            checkOutDate: checkOutDatePicker.date
        )
    }
    
    var minimumCheckInDate: Date {
        return Calendar.current.startOfDay(for: Date())
    }
    
    
    var minimumCheckOutDate: Date {
        let secondsInDay = 60 * 60 * 24
        
        return checkInDatePicker.date.addingTimeInterval(TimeInterval(secondsInDay))
    }
}


// MARK: - Lifecycle

extension CreateBookingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard modelController != nil else {
            preconditionFailure("Model controller not set")
        }
        
        checkInDatePicker.minimumDate = minimumCheckInDate
        checkInDatePicker.date = minimumCheckInDate
        updateDateViews()
    }
    
}


// MARK: - Event handling

extension CreateBookingViewController {
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
    }
    
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        modelController.createBooking(with: bookingChanges) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let booking):
                print("Created booking: \(booking)")
                self.booking = booking
                self.performSegue(withIdentifier: R.segue.createBookingViewController.unwindFromSaveNewBooking, sender: self)
            case .failure(let error):
                self.display(alertMessage: error.localizedDescription, title: "Failed to save new registration")
            }
        }
    }
}


// MARK: - UITableViewDelegate

extension CreateBookingViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row, indexPath.section) {
        case (checkInDatePickerIndexPath.row, checkInDatePickerIndexPath.section):
            return isCheckInPickerVisible ? visibleDatePickerHeight : 0.0
        case (checkOutDatePickerIndexPath.row, checkOutDatePickerIndexPath.section):
            return isCheckOutPickerVisible ? visibleDatePickerHeight : 0.0
        default:
            return UITableView.automaticDimension
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row, indexPath.section) {
        case (checkInDateIndexPath.row, checkInDateIndexPath.section):
            isCheckInPickerVisible.toggle()
            isCheckOutPickerVisible = false
        case (checkOutDateIndexPath.row, checkOutDateIndexPath.section):
            isCheckInPickerVisible = false
            isCheckOutPickerVisible.toggle()
        default:
            break
        }
    }
}


// MARK: - Private Helper Methods

private extension CreateBookingViewController {
    func updateDateViews() {
        checkOutDatePicker.minimumDate = minimumCheckOutDate
        
        checkInDateValueLabel.text = checkInDatePicker.date.pickerDisplayFormat
        checkOutDateValueLabel.text = checkOutDatePicker.date.pickerDisplayFormat
    }
}

