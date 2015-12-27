//
//  AlertManager.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit

typealias AlertHandler = ((UIAlertAction) -> Void)?
typealias AlertActionTuple = (title: String, style: UIAlertActionStyle, handler: AlertHandler)

protocol TextFieldAlertDelegate {
    func inputFinishedWithContent(content: String?)
}

struct Alert {
    private static func actionsFromTuple(tuple: [AlertActionTuple]) -> [UIAlertAction] {
        var actions = [UIAlertAction]()
        
        tuple.forEach { (title, style, handler) -> () in
            actions.append(UIAlertAction(title: title, style: style, handler: handler))
        }
        
        return actions
    }
    
    static func showAlertWithSourceViewController(sourceVC: UIViewController, title: String?, message: String?, actionTuples: [AlertActionTuple]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        actionsFromTuple(actionTuples).forEach { (action) -> () in
            alertController.addAction(action)
        }
        
        sourceVC.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func showInputAlertWithSourceViewController(sourceVC: UIViewController, title: String?, message: String?, confirmTitle: String?, delegate: TextFieldAlertDelegate) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(nil)

        let confirmAction = UIAlertAction(title: confirmTitle, style: .Default) { _ in
            delegate.inputFinishedWithContent(alertController.textFields?.first?.text)
        }
        alertController.addAction(confirmAction)
        sourceVC.presentViewController(alertController, animated: true, completion: nil)
        
    }

}