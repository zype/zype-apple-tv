//
//  Utils.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/23/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

func localized(key: String) -> String {
  return NSLocalizedString(key, comment: "")
}

func getAppDelegate() -> AppDelegate {
  return UIApplication.sharedApplication().delegate as! AppDelegate
}

func alert(message: String, title: String = "", action: (()->())? = nil) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
  let acceptAction = UIAlertAction(title: localized("Messages.OK"), style: .Default) { _ in
    if(action != nil){
      action!()
    }
  }
  alertController.addAction(acceptAction)
  getAppDelegate().window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
}

func errorAlert(message: String) {
  alert(message, title: localized("Messages.ErrorTitle"))
}

func errorDescription(error: NSError) -> String {
  var descriptionKey: String
  if(error.domain == kErrorDomaine) {
    switch error.code {
    case kErrorIncorrectLoginParameters:
      descriptionKey = "Errors.ZYPE.Common"
    case kErrorConsumerNotLoggedIn:
      descriptionKey = "Errors.ZYPE.kErrorConsumerNotLoggedIn"
    case kErrorItemNotInFavorites:
      descriptionKey = "Errors.ZYPE.kErrorItemNotInFavorites"
    default:
      descriptionKey = "Errors.ZYPE.Common"
    }
    return error.localizedDescription.isEmpty ? localized(descriptionKey) : error.localizedDescription
  } else if(error.domain == NSURLErrorDomain) {
    return error.localizedDescription
  }
  return error.localizedDescription.isEmpty ? localized("Errors.Common") : error.localizedDescription
}

func displayError(error: NSError?){
  let description = error == nil ? localized("Errors.ZYPE.Common") : errorDescription(error!)
  errorAlert(description)
}

func showModalProgress(text: String? = nil){
  if let rootVC = getAppDelegate().window?.rootViewController {
    let modalVC = rootVC.storyboard?.instantiateViewControllerWithIdentifier("ModalProgressVC") as! ModalProgressVC
    modalVC.modalPresentationStyle = .Custom
    modalVC.text = text ?? localized("Progress.Default")
    rootVC.presentViewController(modalVC, animated: true, completion: nil)
  }
}

func hideModalProgress(){
  if let rootVC = getAppDelegate().window?.rootViewController {
    rootVC.dismissViewControllerAnimated(true, completion: nil)
  }
}

func isFirstLaunch() -> Bool {
  let defaults = NSUserDefaults.standardUserDefaults()
  let isFirstLaunch = !NSUserDefaults.standardUserDefaults().boolForKey("wasFirstLaunch")
  defaults.setBool(true, forKey: "wasFirstLaunch")
  defaults.synchronize()
  return isFirstLaunch
}

func isValidEmail(email:String) -> Bool {
  let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
  let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
  return emailTest.evaluateWithObject(email)
}
