//
//  ChatLogController.swift
//  fbMessanger
//
//  Created by Sudhanshu Sudhanshu on 4/9/18.
//  Copyright © 2018 Sudhanshu. All rights reserved.
//

import UIKit
import CoreData

private let cellId = "Cell"

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    var friend : Friend? {
        didSet {
            navigationItem.title = friend?.name!
        }
    }
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    var blockOperations = [BlockOperation]()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            if let _ = newIndexPath {
                blockOperations.append(BlockOperation(block: {
                    self.collectionView?.insertItems(at: [newIndexPath!])
                }))
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for block in blockOperations {
                block.start()
            }
        }, completion: { (completed) in
            let item = (self.fetchResultsController.sections?[0].numberOfObjects)! - 1
            let indexPath = IndexPath(item: item, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        })
    }
    
    @objc func handleSend() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let persistentContainer = appDelegate?.persistentContainer {
            let context = persistentContainer.viewContext
            _ = FriendsController.createMessate(inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
            do {
                try context.save()
                inputTextField.text = nil
                
            }catch let err {
                print (err)
            }
        }
    }
    
    var messageInputBottomConstraint : NSLayoutConstraint?
    
    lazy var fetchResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "friend.name = %@", self.friend!.name!)
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate!.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    @objc func addMoreMessages() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let persistentContainer = appDelegate?.persistentContainer {
            let context = persistentContainer.viewContext
            _ = FriendsController.createMessate("1. This is first message to be inserted from add more message buttons", friend: friend!, minutesAgo: 0, context: context, isSender: true)
            _ = FriendsController.createMessate("2. Second message to be inserted from add more message buttons", friend: friend!, minutesAgo: 0, context: context, isSender: true)
            do {
                try context.save()
            }catch let err {
                print (err)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchResultsController.performFetch()
        } catch let err {
            print(err)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMoreMessages))
        
        tabBarController?.tabBar.isHidden = true
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsetsMake(view.safeAreaInsets.top, view.safeAreaInsets.left, view.safeAreaInsets.bottom + 44, view.safeAreaInsets.right)
        collectionView?.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height - 44))
        
        // Register cell classes
        self.collectionView!.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComponents()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_ :)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_ :)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardNotification (_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            
            let isKeyboarShowing = notification.name == .UIKeyboardWillShow
            
//            if isKeyboarShowing {
//                collectionView?.contentInset = UIEdgeInsetsMake(view.safeAreaInsets.top, view.safeAreaInsets.left, view.safeAreaInsets.bottom + (keyboardFrame?.height)!, view.safeAreaInsets.right)
//            }else {
//                collectionView?.contentInset = UIEdgeInsetsMake(view.safeAreaInsets.top, view.safeAreaInsets.left, view.safeAreaInsets.bottom + 44, view.safeAreaInsets.right)
//            }
            
            messageInputBottomConstraint?.constant = isKeyboarShowing ? -((keyboardFrame?.height)! - view.safeAreaInsets.bottom) : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                //
                if isKeyboarShowing {
                    let item = (self.fetchResultsController.sections?[0].numberOfObjects)! - 1
                    let indexPath = IndexPath(item: item, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    private func setupInputComponents () {
        let topBorderView = UIView()
        topBorderView.backgroundColor = .lightGray
        messageInputContainerView.addSubview(topBorderView)
        messageInputContainerView.addConstraintWithFormat("H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintWithFormat("V:|[v0(0.5)]", views: topBorderView)
        
        view.addSubview(messageInputContainerView)
        
        view.addConstraintWithFormat("H:|[v0]|", views: messageInputContainerView)
        messageInputBottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.addConstraint(messageInputBottomConstraint!)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addConstraintWithFormat("H:|-8-[v0]-8-[v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintWithFormat("V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintWithFormat("V:|[v0]|", views: sendButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultsController.sections?[0].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        if let message = fetchResultsController.object(at: indexPath) as? Message, let text = message.text {
            cell.message = message
            
            // Configure the cell
            let size = CGSize(width: view.frame.width - 100, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey : UIFont.systemFont(ofSize: 16)], context: nil)
            
            if !message.isSender {
                cell.profileImageView.isHidden = false
                cell.messageTextView.textColor = .black
                cell.bubbleImageView.tintColor = UIColor.init(white: 0.95, alpha: 1)

                cell.messageTextView.frame = CGRect(origin: CGPoint(x: 48 + 8, y: 0), size: CGSize(width: estimatedFrame.width + 16, height: estimatedFrame.height + 20))
                cell.textBubbleView.frame =  CGRect(origin: CGPoint(x: 48 - 10, y: -4), size: CGSize(width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6))

                cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
                
            }else {
                cell.profileImageView.isHidden = true
                cell.messageTextView.textColor = .white
                cell.bubbleImageView.tintColor = .blue
                
                cell.messageTextView.frame = CGRect(origin: CGPoint(x: view.frame.width - (estimatedFrame.width + 16 + 16), y: 0), size: CGSize(width: estimatedFrame.width + 16, height: estimatedFrame.height + 20))
                cell.textBubbleView.frame =  CGRect(origin: CGPoint(x: view.frame.width - (estimatedFrame.width + 16 + 16 + 8), y: -4), size: CGSize(width: estimatedFrame.width + 16 + 8 + 8, height: estimatedFrame.height + 20 + 6))
                
                cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage

            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let message = fetchResultsController.object(at: indexPath) as? Message, let text = message.text {
            let size = CGSize(width: view.frame.width - 100, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey : UIFont.systemFont(ofSize: 16)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
}


class ChatLogMessageCell: BaseCell {
    let messageTextView: UITextView = {
       let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Sample Message"
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15.0
        view.clipsToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .red
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubbleImage = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var message: Message? {
        didSet {
            messageTextView.text = message!.text
            if let profileImage = message?.friend?.profileImageName {
                profileImageView.image = UIImage(named: profileImage)
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()

        addSubview(textBubbleView)
        addSubview(messageTextView)
        
        addSubview(profileImageView)
        addConstraintWithFormat("H:|-8-[v0(30)]", views: profileImageView)
        addConstraintWithFormat("V:[v0(30)]|", views: profileImageView)
        
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstraintWithFormat("H:|[v0]|", views: bubbleImageView)
        textBubbleView.addConstraintWithFormat("V:|[v0]|", views: bubbleImageView)
    }
}


