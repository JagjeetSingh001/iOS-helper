
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import SDWebImage

class newChatViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var accessoryView: CustomView!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var imgAdd: UIImageView!
    
    @IBOutlet weak var txtMessageHeight: NSLayoutConstraint!
    @IBOutlet weak var accessoryViewBottom: NSLayoutConstraint!
    var messageList = [[String : Any]]()
    var minTextViewHeight: CGFloat = 40
    var maxTextViewHeight: CGFloat = 100
    
    var arrMessages = [[String : Any]]()
//    var recArrMessages = [[String : Any]]()
//    var mainMsgsArr = [[String : Any]]()
    
    var imagedata = Data()
    let imagePicker = UIImagePickerController()
    
    //    var currentUserId = Auth.auth().currentUser!.uid
    
    var dict = [String : Any]()
    var receiverDict = [String : Any]()
    
    var receiverData = [userMVC]()
    var otherVisiting = false
    
    var msgDict = [String : Any]()
    
    var receiverName = String()
    var receiverProfile = String()
    //    var userToken = String()
    var senderName = String()
    var senderProfile = String()
    
    var dateString = String()
    
    var currentUserName = String()
    
    var senderID = "1"
    var receiverID = "2"
    
    var currentUserId = "2"
    var myUser: [User]? {didSet {}}
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.disabledToolbarClasses.append(newChatViewController.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(newChatViewController.self)
        
        self.hideKeyboardWhenTappedAround()
        
        //        self.userId = dict["id"] as? String ?? "id"
        //        self.userName = dict["name"] as? String ?? "name"
        //        self.lblTitle.text = self.userName
        //        self.userProfile = dict["profile"] as? String ?? dict["image"] as? String ?? "image"
       

        myUser = User.readUserFromArchive()
        
        print("myUser: ",myUser![0].username as Any)
        self.senderName = myUser![0].username
        self.senderProfile = (AppUtility?.detectURL(ipString: myUser![0].profile_pic))!
        
        self.senderID = UserDefaults.standard.string(forKey: "userID")!
        
        if otherVisiting == true{
            let obj = receiverData[0]
            self.receiverID = obj.userID
            self.receiverName = obj.username
            self.lblTitle.text = self.receiverName
            self.receiverProfile = (AppUtility?.detectURL(ipString:obj.userProfile_pic))!
            print("receiverProfile: ",receiverProfile)
            
        }else{
            self.receiverID = receiverDict["rid"] as? String ?? "receiver id"
            self.receiverName = receiverDict["name"] as? String ?? "name"
            //        self.receiverID = msgDict["rid"] as? String ?? "receiver id"
            self.lblTitle.text = self.receiverName
            self.receiverProfile = ((AppUtility?.detectURL(ipString: receiverDict["pic"] as? String ?? ""))!)
            print("receiverProfile: ",receiverProfile)
        }
        
        
        //        let user = UserDefaults.standard.value(forKey: "userlogin") as? [String : Any] ?? [:]
        //        self.currentUserName = user["name"] as? String ?? "name"
        
        txtMessage.text = "Send Message..."
        txtMessage.textColor = UIColor.lightGray
        
        txtMessage.delegate = self
        
        ChatDBhandler.shared.fetchMessage(senderID: senderID, receiverID: receiverID) { (isSuccess, message) in
            self.arrMessages.removeAll()
            if isSuccess == true
            {
                for key in message
                {
                    let messages = key.value as? [String : Any] ?? [:]
                    self.arrMessages.append(messages)
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ssZ"
//                   let dateTime = dateFormatter.date(from: dateStr as! String)
                    self.arrMessages.sort(by: { dateFormatter.date(from: $0["timestamp"] as! String)?.compare(dateFormatter.date(from: $1["timestamp"] as! String) ?? Date()) == .orderedAscending })
                    _  = ""
                    
                   
//                    for msg in self.arrMessages{
//
//                        let tmpDate = msg["timestamp"] as? String ?? ""
//                        let dateStr = tmpDate.components(separatedBy: " ")[0]
//
//                        if tmpdate != dateStr {
//                            tmpdate = dateStr
//
//
//                            let results = self.arrMessages.filter { ($0["timestamp"] as? String ?? "").components(separatedBy: " ")[0] == dateStr }
//
//
//
//                            let tmpObj = ["date": tmpdate,"messages":results] as [String : Any]
//                            self.messageList.append(tmpObj)
//                        }
//
//
//                    }
//                    self.arrMessages.sort(by: { ("\($0["time"]!)") < ("\($1["time"]!)") })
                    self.scrollToBottom()
                }
                
                self.tblView.reloadData()
            }
        }

        
        self.txtMessage.tintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        self.txtMessage.tintColorDidChange()
        self.txtMessage.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.imagePicker.delegate = self
        let imgTap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapImage(sender:)))
        imgAdd.isUserInteractionEnabled = true
        imgAdd.addGestureRecognizer(imgTap)
        
    }
    
    
    
    //MARK:- scroll to bottom
    func scrollToBottom()
    {
        if arrMessages.count > 0
        {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.arrMessages.count-1, section: 0)
                self.tblView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    //MARK:- tap gesture
    @objc func tapImage(sender:UITapGestureRecognizer)
    {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:- image picker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            self.dismiss(animated: true, completion: nil)
            self.imagedata = pickedImage.jpegData(compressionQuality: 0.25)!
            
            let time = Date().millisecondsSince1970
            let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ssZ"
            let dateStr = dateFormatter.string(from: Date())

            AppUtility?.startLoader(view: self.view)
            ChatDBhandler.shared.sendImage(senderID: senderID, receiverID: receiverID, image: imagedata, seen: false, time: "",date: "\(dateStr)", type: "image") { (result, url) in
                if result == true
                {
                    print("image sent")

                    ChatDBhandler.shared.userChatInbox(senderID: self.senderID, receiverID: self.receiverID, image: self.receiverProfile, name: self.receiverName, message: "Send an image..", type: "image", seen: false, timestamp: time, date: "\(dateStr)", status: "1") { (result) in
                        if result == true
                        {
                            print("user Sent")
                            self.sendMsgNoti()
                            AppUtility?.stopLoader(view: self.view)
                            //                            ChatDBhandler.shared.sendPushNotification(to: self.userToken, title: self.currentUserName, body: "Send an Image")
                        }
                    }
                    

                }
                
            }
        }
        else
        {
            print("Error in pick Image")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Change the height of textView when type
    func textViewDidChange(_ textView: UITextView)
    {
        var height = textView.contentSize.height
        
        if height < minTextViewHeight
        {
            height = minTextViewHeight
        }
        
        if (height > maxTextViewHeight)
        {
            height = maxTextViewHeight
        }
        
        if height != txtMessageHeight.constant
        {
            txtMessageHeight.constant = height
            textView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    //    MARK:- PLACEHOLDER OF TEXT VIEW
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    //    func textViewDidEndEditing(_ textView: UITextView) {
    //        if textView.text.isEmpty {
    //            textView.text = "Send Message..."
    //            textView.textColor = UIColor.lightGray
    //        }
    //    }
    
    //MARK:- keyboardWillShow
    @objc func keyboardWillShow(notification: Notification)
    {
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let keyboardHeight = keyboardSize?.height
        
        self.accessoryViewBottom.constant = -(keyboardHeight! - view.safeAreaInsets.bottom)
        
        UIView.animate(withDuration: 0.5)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK:- keyboardWillHide
    @objc func keyboardWillHide(notification: Notification)
    {
        //        txtMessage.text = "Send Message..."
        //        txtMessage.textColor = UIColor.lightGray
        
        self.accessoryViewBottom.constant =  0 // or change according to your logic
        
        UIView.animate(withDuration: 0.5)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK:- button Actions
    @IBAction func btnBackAction(_ sender: Any)
    {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
       
    }
    
    
    //MARK:- SEND MSG ACTION
    //    private func textView(textView: UITextView, shouldChangeTextInRange  range: NSRange, replacementText text: String) -> Bool {
    //      if (text == "\n") {
    //         textView.resignFirstResponder()
    //         sendPressed()
    //      }
    //      return true
    //    }
    //
    //    func sendPressed() {
    //        print("send")
    //    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            sendPressed()
        }
        return true
        
    }
    
    func sendPressed() {
        if self.txtMessage.text == ""
        {
            AppUtility!.displayAlert(title: "customChat", message: "Please type your message")
        }
        else
        {
            let time = Date().millisecondsSince1970
            /*
             ChatDBhandler.shared.sendMessages(uid: self.currentUserId, merchantId: self.userId, message: self.txtMessage.text!, seen: false, time: time, type: "text") { (isSuccess) in
             if isSuccess == true
             {
             print("Message Sent")
             }
             }
             */
            //            AppUtility?.startLoader(view: self.view)  yyyy-MM-dd'T'HH:mm:ssZ
            let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ssZ"
            let dateStr = dateFormatter.string(from: Date())
            print("sender: \(senderID) && receiver: \(receiverID)")
            
            print("self.txtMessage.text: ",self.txtMessage.text!)
            ChatDBhandler.shared.sendMessage(senderID: senderID, receiverID: receiverID, senderName: self.senderName, message: self.txtMessage.text!, seen: false, time: "", date: "\(dateStr)", type: "text") { (isSuccess) in
                if isSuccess == true{
                    print("Message Sent")
                }
            }
            
            //            ChatDBhandler.shared.sendPushNotification(to: self.userToken, title: self.currentUserName, body: self.txtMessage.text!)
            
            /*
             ChatDBhandler.shared.userChat(uid: self.currentUserId, userId: self.userId, image: self.userProfile, name: self.userName, message: self.txtMessage.text, type: "text", seen: false, timestamp: time) { (result) in
             if result == true
             {
             print("User Sent")
             }
             }
             */
            ChatDBhandler.shared.userChatInbox(senderID: self.senderID, receiverID: self.receiverID, image: receiverProfile, name: self.receiverName, message: self.txtMessage.text!, type: "text", seen: false, timestamp: time, date: "\(dateStr)", status: "1") { (result) in
                if result == true
                {
                    print("user Sent")
                    self.sendMsgNoti()
                    self.txtMessage.text = "Send Message..."
                    self.txtMessage.textColor = UIColor.lightGray
                    //                    ChatDBhandler.shared.sendPushNotification(to: self.userToken, title: self.currentUserName, body: "Send an Image")
                    //                    AppUtility?.stopLoader(view: self.view)
                    
                  
                }
            }
                        
                        
            self.txtMessageHeight.constant = self.minTextViewHeight
        }
    }
    
    
    
    //MARK:- tableView delegate
//    // MARK: - Table view data source
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return self.messageList.count
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.getSectionItems(section).count
//    }
    
//      func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let messages = self.messageList[section]["date"] as? String ?? ""
//
//        return messages
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
//        let messages = self.messageList[section]["messages"] as! [[String:Any]]
        if self.arrMessages.count == 0
        {
            self.lblMessage.isHidden = false
            return 0
        }
        else
        {
            self.lblMessage.isHidden = true
            return self.arrMessages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        /*
        mainMsgsArr.removeAll()
        mainMsgsArr.append(contentsOf: arrMessages)
        mainMsgsArr.append(contentsOf: recArrMessages)
        mainMsgsArr.sort(by: { ("\($0["time"]!)") < ("\($1["time"]!)") })
        
        */
        
//        self.arrMessages = self.messageList[indexPath.section]["messages"] as! [[String:Any]]

        
        let time = (self.arrMessages[indexPath.row]["time"] as? Double)
        _ = Date(timeIntervalSince1970: time ?? 0.0/1000)
        
        let dateStr = self.arrMessages[indexPath.row]["timestamp"] ?? ""
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ssZ"
        let dateTime = dateFormatter.date(from: dateStr as! String)
        
        dateFormatter.dateFormat = "dd-MM-yy' 'HH:mm a"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        let dateString = dateFormatter.string(from: dateTime ?? Date())
        
        let from = self.arrMessages[indexPath.row]["sender_id"] as? String ?? "from"
        let type = self.arrMessages[indexPath.row]["type"] as? String ?? "type"
        let picture = arrMessages[indexPath.row]["pic_url"] as? String ?? "text"
        
        if self.senderID == from
        {
            if type == "text"
            {
                let chatCell1 = tableView.dequeueReusableCell(withIdentifier: "chatCell1") as! ChatTableViewCell
                chatCell1.lblMessage.text = arrMessages[indexPath.row]["text"] as? String ?? "text"
                chatCell1.lblDate.text = dateString
                return chatCell1
            }
            else if type == "profileShare" {
                let chatCell5 = tableView.dequeueReusableCell(withIdentifier: "chatCell5") as! ChatTableViewCell
                let userDetail = self.convertToDictionary(text: arrMessages[indexPath.row]["text"] as? String ?? "")
                chatCell5.lblUserName.text = userDetail?["username"] as? String ?? "text"
                chatCell5.lblLastMessage.text = userDetail?["fullName"] as? String ?? "text"
               
                chatCell5.imgUser.sd_setImage(with: URL(string: userDetail?["pic"] as? String ?? "text"), placeholderImage: UIImage(named: "videoPlaceholder"))
                return chatCell5
            }  else if type == "video" {
                let chatCell2 = tableView.dequeueReusableCell(withIdentifier: "chatCell2") as! ChatTableViewCell
                chatCell2.imgMessage.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                chatCell2.imgMessage.sd_setImage(with: URL(string: picture), placeholderImage: UIImage(named: "videoPlaceholder"))
                chatCell2.lblDate.text = dateString
                chatCell2.playImage.isHidden = false
                return chatCell2
            }
            else if type == "productShare" {
               let chatCell2 = tableView.dequeueReusableCell(withIdentifier: "chatCell2") as! ChatTableViewCell
               chatCell2.imgMessage.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                
                let userDetail = self.convertToDictionary(text: arrMessages[indexPath.row]["text"] as? String ?? "")
              
               chatCell2.imgMessage.sd_setImage(with: URL(string: userDetail?["pic"] as? String ?? "text"), placeholderImage: UIImage(named: "videoPlaceholder"))
               chatCell2.lblDate.text = dateString
               chatCell2.playImage.isHidden = true
               return chatCell2
           }
            else
            {
                let chatCell2 = tableView.dequeueReusableCell(withIdentifier: "chatCell2") as! ChatTableViewCell
                chatCell2.imgMessage.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                chatCell2.imgMessage.sd_setImage(with: URL(string: picture), placeholderImage: UIImage(named: "videoPlaceholder"))
                
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.imagePreview(_:)))
                chatCell2.imgMessage.isUserInteractionEnabled = true
                chatCell2.imgMessage.addGestureRecognizer(tap)
                chatCell2.playImage.isHidden = true
                
                chatCell2.lblDate.text = dateString
                return chatCell2
            }
        }
        else
        {
            if type == "text"
            {
                let chatCell3 = tableView.dequeueReusableCell(withIdentifier: "chatCell3") as! ChatTableViewCell
                chatCell3.lblMessage.text = arrMessages[indexPath.row]["text"] as? String ?? "text"
                chatCell3.lblDate.text = dateString
                return chatCell3
            } else if type == "profileShare" {
                let chatCell6 = tableView.dequeueReusableCell(withIdentifier: "chatCell6") as! ChatTableViewCell
                let userDetail = self.convertToDictionary(text: arrMessages[indexPath.row]["text"] as? String ?? "")
                chatCell6.lblUserName.text = userDetail?["username"] as? String ?? "text"
                chatCell6.lblLastMessage.text = userDetail?["fullName"] as? String ?? "text"
               
                chatCell6.imgUser.sd_setImage(with: URL(string: userDetail?["pic"] as? String ?? "text"), placeholderImage: UIImage(named: "videoPlaceholder"))
                return chatCell6
            }  else if type == "video" {
                let chatCell4 = tableView.dequeueReusableCell(withIdentifier: "chatCell4") as! ChatTableViewCell
                chatCell4.imgMessage.sd_imageIndicator = SDWebImageActivityIndicator.gray
                chatCell4.imgMessage.sd_setImage(with: URL(string: picture), placeholderImage: UIImage(named: "videoPlaceholder"))
                chatCell4.playImage.isHidden = false
                chatCell4.lblDate.text = dateString
                return chatCell4
            }
            else if type == "productShare" {
               let chatCell4 = tableView.dequeueReusableCell(withIdentifier: "chatCell2") as! ChatTableViewCell
                chatCell4.imgMessage.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                
                let userDetail = self.convertToDictionary(text: arrMessages[indexPath.row]["text"] as? String ?? "")
              
                chatCell4.imgMessage.sd_setImage(with: URL(string: userDetail?["pic"] as? String ?? "text"), placeholderImage: UIImage(named: "videoPlaceholder"))
                chatCell4.lblDate.text = dateString
                chatCell4.playImage.isHidden = true
               return chatCell4
           }
            else
            {
                let chatCell4 = tableView.dequeueReusableCell(withIdentifier: "chatCell4") as! ChatTableViewCell
                chatCell4.imgMessage.sd_imageIndicator = SDWebImageActivityIndicator.gray
                chatCell4.imgMessage.sd_setImage(with: URL(string: picture), placeholderImage: UIImage(named: "videoPlaceholder"))
                
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.imagePreview(_:)))
                chatCell4.imgMessage.isUserInteractionEnabled = true
                chatCell4.imgMessage.addGestureRecognizer(tap)
                
                chatCell4.lblDate.text = dateString
                chatCell4.playImage.isHidden = true
                return chatCell4
            }
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = self.arrMessages[indexPath.row]["type"] as? String ?? "type"
        if type == "profileShare" {
          
           let userDetail = self.convertToDictionary(text: arrMessages[indexPath.row]["text"] as? String ?? "")
            let otherUserID = userDetail?["id"] as! String
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "newProfileVC") as!  newProfileViewController
            vc.isOtherUserVisting = true
            vc.hidesBottomBarWhenPushed = true
            vc.otherUserID = otherUserID
            UserDefaults.standard.set(otherUserID, forKey: "otherUserID")
            navigationController?.pushViewController(vc, animated: true)
        }  else if type == "productShare" {
            let storyMain = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyMain.instantiateViewController(withIdentifier: "ProductDetailController") as! ProductDetailController
            let userDetail = self.convertToDictionary(text: arrMessages[indexPath.row]["text"] as? String ?? "")
             
            vc.productID =  userDetail?["id"] as! String
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if type == "video" {
           
             let videoID = arrMessages[indexPath.row]["video_id"] as? String ?? ""
          getVideo(videoId: videoID)
//            let vc = storyboard?.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
//            vc.videosMainArr = videosMainArr
//            vc.currentIndex = indexPath
//            vc.otherUserID =  self.otherUserID
//            vc.isOtherController =  true
//            vc.hidesBottomBarWhenPushed = true
//            navigationController?.pushViewController(vc, animated: true)
       }
    }
    
    func getVideo(videoId:String){
        AppUtility?.startLoader(view: self.view)
        var notiVidDataArr = [VideoData]()
        ApiHandler.sharedInstance.showVideoDetail(user_id: UserDefaults.standard.string(forKey: "userID")!, video_id:videoId) { (isSuccess, response) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    
                    let resMsg = response?.value(forKey: "msg") as! [String:Any]
                    
                    let videoObj = VideoData(data: resMsg["data"] as? [String : Any] ?? [:])
                     
                    notiVidDataArr.append(videoObj)
                     
                    AppUtility?.stopLoader(view: self.view)
                   /* let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeFeedVC") as! homeFeedViewController
                    vc.userVideoArr = self.notiVidDataArr
                    vc.indexAt = ip*/
                    let vc =  self.storyboard?.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
                    vc.videosMainArr =  notiVidDataArr
                    vc.currentIndex = IndexPath(row: 0, section: 0)
                    vc.isOtherController =  true
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    AppUtility?.stopLoader(view: self.view)
                    print("!200: ",response as Any)
                }
                

            }else{
                AppUtility?.startLoader(view: self.view)
              /*  let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeFeedVC") as! homeFeedViewController
                vc.userVideoArr = self.notiVidDataArr
                vc.indexAt = ip*/
                let vc =  self.storyboard?.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
                vc.videosMainArr =  notiVidDataArr
                vc.currentIndex = IndexPath(row: 0, section: 0)
                vc.isOtherController =  true
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    //MARK:- tap getsure recognizer
    @objc func imagePreview(_ gesture: UITapGestureRecognizer)
    {
        let tapLocation = gesture.location(in: self.tblView)
        let indexPath = self.tblView.indexPathForRow(at: tapLocation)!
        
        let type = self.arrMessages[indexPath.row]["type"] as? String ?? "type"
        let picture = arrMessages[indexPath.row]["pic_url"] as? String ?? "pic_url"
        
        print("pic: ",picture)
        if type == "image"
        {
            let imagePreviewVC = self.storyboard?.instantiateViewController(withIdentifier: "imagePreviewVC") as! ImagePreviewViewController
            imagePreviewVC.imgUrl = picture
            imagePreviewVC.modalPresentationStyle = .fullScreen
            navigationController?.present(imagePreviewVC, animated: true, completion: nil)
        }
        if type == "productShare" {
            let storyMain = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyMain.instantiateViewController(withIdentifier: "ProductDetailController") as! ProductDetailController
            let userDetail = self.convertToDictionary(text: arrMessages[indexPath.row]["text"] as? String ?? "")
             
            vc.productID =  userDetail?["id"] as! String
            self.navigationController?.pushViewController(vc, animated: true)
        }
           
        if type == "video" {
               
                 let videoID = arrMessages[indexPath.row]["video_id"] as? String ?? ""
              getVideo(videoId: videoID)
        }
    }
    
    func sendMsgNoti(){
        ApiHandler.sharedInstance.sendMessageNotification(senderID: senderID, receiverID: receiverID, msg: txtMessage.text!, title: senderName) { (isSuccess, response) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200{
                    print("msg noti sent: ")
                    self.txtMessage.text = "Send Message..."
                    self.txtMessage.textColor = UIColor.lightGray
                    
                }else{
                    print("!200: ",response as Any)
                    self.txtMessage.text = "Send Message..."
                    self.txtMessage.textColor = UIColor.lightGray
                }


            }
        }
    }
}

