//
//  TipViewController.swift
//  tips
//
//  Created by constance_jiang on 4/27/16.
//  Copyright © 2016 constance_jiang. All rights reserved.
//

import UIKit

class TipViewController: UIViewController, UITextFieldDelegate {
  let tipPercentages = [0.18, 0.2, 0.22]
  var totalTextLabelInitialFrame: CGRect!
  var totalAmountLabelInitialFrame: CGRect!

  @IBOutlet weak var tipControl: UISegmentedControl!
  @IBOutlet weak var tipLabel: UILabel!
  @IBOutlet weak var billField: UITextField!
  @IBOutlet weak var totalTextLabel: UILabel!
  @IBOutlet weak var totalAmountLabel: UILabel!
  @IBOutlet weak var partyCountField: UITextField!
  @IBOutlet weak var tipTextLabel: UILabel!
  @IBOutlet weak var tipAmountLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    totalTextLabelInitialFrame = totalTextLabel.frame
    totalAmountLabelInitialFrame = totalAmountLabel.frame

    billField.delegate = self
    partyCountField.delegate = self

    setupAppNotifications()
    setUpView()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    tipControl.selectedSegmentIndex = DefaultValuesUtility.getDefaultTipIndex()
    updateTipAndTotal()
  }

  @IBAction func onEditingChanged(sender: AnyObject) {
    updateTipAndTotal()
  }

  @IBAction func onTap(sender: AnyObject) {
    view.endEditing(true)

    UIView.animateWithDuration(0.4, animations: {
      self.setTotalBillPosOnEndEditing()
    })
  }

  func textFieldDidBeginEditing(textField: UITextField) {
    textField.selectAll(nil)

    UIView.animateWithDuration(0.4, animations: {
      self.setTotalBillPosOnBeginEditing()
    })
  }

  func textFieldDidEndEditing(textField: UITextField) {
    guard textField == billField else {
      return
    }

    // normalize bill amount to $xx.xx format with two decimal places
    // ex) 10 -> 10.00
    textField.text = convertDoubleToString(billFieldDoubleValue(), addDollarSign: false)
  }

  func appWillEnterForeground() {
    setUpView()
  }

  func appDidEnterBackground() {
    saveDefaultValues()
  }

  private func setupAppNotifications() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self,
                                   selector: #selector(TipViewController.appWillEnterForeground),
                                   name: UIApplicationWillEnterForegroundNotification,
                                   object: nil)
    notificationCenter.addObserver(self,
                                   selector: #selector(TipViewController.appDidEnterBackground),
                                   name: UIApplicationDidEnterBackgroundNotification,
                                   object: nil)
  }

  private func setUpView() {
    setDefaultValues()
    updateTipAndTotal()
    // don't animate total bill amount when opening app
    setTotalBillPosOnBeginEditing()
    billField.becomeFirstResponder()
  }

  private func setDefaultValues() {
    let defaultBillAmount = DefaultValuesUtility.getDefaultBillAmount()
    let defaultPartyCount = DefaultValuesUtility.getDefaultPartyCount()
    billField.text = convertDoubleToString(defaultBillAmount, addDollarSign: false)
    partyCountField.text = String(defaultPartyCount)
  }

  private func saveDefaultValues() {
    DefaultValuesUtility.saveBillAmount(billFieldDoubleValue())
    DefaultValuesUtility.savePartyCount(Int(partyCountField.text!)!)
    DefaultValuesUtility.saveLastOpenedDate()
  }

  private func updateTipAndTotal() {
    let billAmount = billFieldDoubleValue()
    let tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
    let totalTip = billAmount * tipPercentage
    let totalBill = billAmount + totalTip

    tipLabel.text = convertDoubleToString(amountPerPerson(totalTip), addDollarSign: true)
    totalAmountLabel.text = convertDoubleToString(amountPerPerson(totalBill), addDollarSign: true)
  }

  private func amountPerPerson(amount: Double) -> Double {
    let partyCount = NSString(string: partyCountField.text!).doubleValue

    guard partyCount > 0 else {
      return 0
    }

    return amount / partyCount
  }

  private func convertDoubleToString(amount: Double, addDollarSign: Bool) -> String {
    var formatString = "%.2f"

    if addDollarSign {
      formatString = "$%.2f"
    }

    return String(format: formatString, amount)
  }

  private func billFieldDoubleValue() -> Double {
    return NSString(string: billField.text!).doubleValue
  }

  private func setTotalBillPosOnBeginEditing() {
    setTotalBillYPos(totalTextY: tipTextLabel.frame.origin.y,
                     totalAmountY: tipAmountLabel.frame.origin.y)
  }

  private func setTotalBillPosOnEndEditing() {
    setTotalBillYPos(totalTextY: totalTextLabelInitialFrame.origin.y,
                     totalAmountY: totalAmountLabelInitialFrame.origin.y)
  }

  private func setTotalBillYPos(totalTextY totalTextY: CGFloat, totalAmountY: CGFloat) {
    totalTextLabel.frame.origin.y = totalTextY
    totalAmountLabel.frame.origin.y = totalAmountY
  }
}
