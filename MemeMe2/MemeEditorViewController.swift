//
//  MemeEditorViewController.swift
//  MemeMe2
//
//  Created by Eric Wei on 2017-01-10.
//  Copyright © 2017 EricWei. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let textFieldsDelegate = TextFieldsDelegate()
    var memedImage: UIImage!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFields(textField: topTextField)
        setTextFields(textField: bottomTextField)
    }
    
    func setTextFields(textField:UITextField) {
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self.textFieldsDelegate
        
        textField.textAlignment = .center
        textField.borderStyle = UITextBorderStyle.none
        textField.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = imageView.image != nil
        //cancelButton.isEnabled = imageView.image != nil
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        //Hide toolbar and navbar
        topToolBar.isHidden = true
        bottomToolBar.isHidden = true
        
        //Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        topToolBar.isHidden = false
        bottomToolBar.isHidden = false
        
        return memedImage
    }
    
    func save() {
        let meme = Meme(topString: topTextField.text!, bottomString: bottomTextField.text!, origImage: imageView.image!, memeImage: memedImage)
            
        //add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func pick(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pick(sourceType: .camera)
    }
    
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pick(sourceType: .photoLibrary)
    }
    
    @IBAction func shareMemeImage(_ sender: Any) {
        //generate a memed image
        memedImage = generateMemedImage()
        //define an instance of the ActivityViewController, pass the ActivityViewController a memedImage as an activity item
        let viewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        //present the ActivityViewController
        present(viewController, animated: true, completion: nil)
        
        viewController.completionWithItemsHandler = {
            activity,completed,items,error in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
                print("Image SAVED!!!")
            }
        }
    }
    
    
//    @IBAction func exitMemeEditor(_ sender: Any) {
////        topTextField.text = "TOP"
////        bottomTextField.text = "BOTTOM"
////        imageView.image = nil
//        dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func exitMemeEditor(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

