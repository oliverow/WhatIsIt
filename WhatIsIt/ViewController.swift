//
//  ViewController.swift
//  WhatIsIt
//
//  Created by Oliver Wang on 2018-09-12.
//  Copyright © 2018 Oliver Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Properties
    @IBOutlet weak var ImageUploaded: UIImageView!
    @IBOutlet weak var AnswerTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Image Functions
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        ImageUploaded.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    // API functions
    func testGet() {
        let url = URL(string: "http://192.168.2.37:3000/test")! // "https://reqres.in/api/users/2")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error == nil {
                DispatchQueue.main.sync {
                    do {
                        print(String(decoding: data!, as: UTF8.self))
                        let jsonArray = try JSONSerialization.jsonObject(with: data!, options : .allowFragments) as! Dictionary<String,Any>
                        //let json = jsonArray["data"] as! Dictionary<String, Any>
                        //print(json["id"])
                        self.AnswerTextField.text = jsonArray["status"] as? String
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }
        task.resume()
    }
    
    func uploadImage() {
        let ImageData = UIImageJPEGRepresentation(ImageUploaded.image!, 1)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: "http://192.168.2.37:3000/image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = ""
        let filePathKey = "file"
        let filename = "upload.jpg"
        let mimetype = "image/jpg"
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimetype)\r\n\r\n")
        var data = body.data(using: .utf8)!
        data.append(ImageData!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                DispatchQueue.main.sync {
                    do {
                        print(String(decoding: data!, as: UTF8.self))
                        let jsonArray = try JSONSerialization.jsonObject(with: data!, options : .allowFragments) as! Dictionary<String,Any>
                        var answer = jsonArray["result"] as! String
                        let firstAns = String(answer.split(separator: "\n")[0])
                        self.AnswerTextField.text = firstAns
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }
        task.resume()
    }

    // Actions
    @IBAction func TabImage(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePickerController.sourceType = .camera
        }
        else {
            imagePickerController.sourceType = .photoLibrary
        }
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func PressHelpMeButton(_ sender: UIButton) {
        // AnswerTextField.text = "Test"
        uploadImage()
        //testGet()
    }
    
}
