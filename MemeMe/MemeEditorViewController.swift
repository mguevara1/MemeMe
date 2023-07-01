//
//  ViewController.swift
//  MemeMe
//
//  Created by Marco Guevara on 11/2/22.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBarBottom: UIToolbar!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        configureTextField(textField: topTextField)
        configureTextField(textField: bottomTextField)
        
        shareButton.isEnabled = false
        
    }
    
    private func configureTextField(textField: UITextField){
        let memeTextAttributes: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.strokeColor: UIColor.black, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.underlineColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name:"Impact", size: 40.0)!,
            NSAttributedString.Key.strokeWidth: -3.5]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        #if targetEnvironment(simulator)
            cameraButton.isEnabled = false;
        #else
            cameraButton.isEnabled = true;
        #endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromKeyboardNotifications()
    }
    
    func pickImage(source: UIImagePickerController.SourceType?){
        let imagePicker = UIImagePickerController()
        if let sourceType = source{
            imagePicker.sourceType = sourceType
        }
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    

    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        if (sender.tag == 0){
            pickImage(source: .camera)
        }else{
            pickImage(source: nil)
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let activityViewController = self.share(items: [generateMemedImage()], ipad: (true, self.view))
        self.present(activityViewController, animated: true)
        activityViewController.completionWithItemsHandler = {
            _, completed, _, _ in
            if completed {
                self.save()
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        imageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imageView.contentMode = .scaleAspectFit
                imageView.image = pickedImage
            shareButton.isEnabled = true
            }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {

        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func save() {

        let memedImage = generateMemedImage()
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {

        
        toolBar.isHidden = true
        toolBarBottom.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        toolBar.isHidden = false
        toolBarBottom.isHidden = false 

        return memedImage
    }
    
    private func share(items: [Any],
                       excludedActivityTypes: [UIActivity.ActivityType]? = nil,
                       ipad: (forIpad: Bool, view: UIView?) = (false, nil)) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: items,
                                                              applicationActivities: nil)
        if ipad.forIpad {
            activityViewController.popoverPresentationController?.sourceView = ipad.view
        }
        
        if let excludedActivityTypes = excludedActivityTypes {
            activityViewController.excludedActivityTypes = excludedActivityTypes
        }
        
        return activityViewController
    }
}

