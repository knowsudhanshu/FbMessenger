//
//  ViewController.swift
//  fbMessanger
//
//  Created by Sudhanshu Sudhanshu on 4/5/18.
//  Copyright © 2018 Sudhanshu. All rights reserved.
//

import UIKit
import CoreData

private let cellId = "cellId"
class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    
    lazy var fetchResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "lastMessage != nil")
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate!.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    var blockOperations = [BlockOperation]()
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            blockOperations.append(BlockOperation(block: {
                self.collectionView?.insertItems(at: [newIndexPath!])
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for operation in blockOperations {
                operation.start()
            }
        }, completion: { (completed) in
            let lastItem = self.fetchResultsController.sections![0].numberOfObjects - 1
            let indexPath = IndexPath(item: lastItem, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc func addMoreFriends () {
        print("addMoreFriends")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let persistentContainer = appDelegate?.persistentContainer {
            let context = persistentContainer.viewContext
            
            let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            mark.name = "Mark Zukerberg"
            mark.profileImageName = "zuckprofile"
            
            _ = FriendsController.createMessate("Hello, my name is mark. Nice to meet you.", friend: mark, minutesAgo: 0, context: context)
            
            
            let bill = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            bill.name = "Bill Gates"
            bill.profileImageName = "bill_profile"
            
            _ = FriendsController.createMessate("Hello, I love windows computers!", friend: bill, minutesAgo: 0, context: context)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMoreFriends))
        
        collectionView?.backgroundColor = .white

        collectionView?.alwaysBounceVertical = true
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupData()
        
        do {
            try fetchResultsController.performFetch()
        }catch let err {
            print(err)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        if let friend = fetchResultsController.object(at: indexPath) as? Friend, let message = friend.lastMessage {
            cell.message = message
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let chatLogVC = ChatLogController(collectionViewLayout: layout)
        chatLogVC.friend = fetchResultsController.object(at: indexPath) as? Friend
        self.navigationController?.pushViewController(chatLogVC, animated: true)
    }
    
}


class MessageCell: BaseCell {
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .blue : .white
            nameLabel.textColor = isHighlighted ? .white : .black
            messageLabel.textColor = isHighlighted ? .white : .black
            timeLabel.textColor = isHighlighted ? .white : .black
        }
    }
    var message: Message? {
        didSet {
            nameLabel.text = message?.friend?.name
            messageLabel.text = message?.text
            
            if let profileImage = message?.friend?.profileImageName {
                profileImageView.image = UIImage(named: profileImage)
                hasReadImageView.image = UIImage(named: profileImage)
            }
            
            
            
            if let date = message?.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                let elapsedTimeInSeconds = Date().timeIntervalSince(date)
                let secondInADay : TimeInterval = 60 * 60 * 24
                if elapsedTimeInSeconds > 7 * secondInADay {
                    dateFormatter.dateFormat = "MM/dd/yy"
                }else if elapsedTimeInSeconds > secondInADay {
                    dateFormatter.dateFormat = "EEE"
                }
                timeLabel.text = dateFormatter.string(from: date)
            }
            
        }
    }
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .yellow
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let dividerView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Sudhanshu Srivastava"
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "This is message from your friend and more."
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "12:05 pm"
        label.textAlignment = .right
        return label
    }()
    
    let hasReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .yellow
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func setupViews() {
        
        setupContainerView()
        
        addSubview(profileImageView)
        addConstraintWithFormat("H:|-12-[v0(68)]|", views: profileImageView)
        addConstraintWithFormat("V:[v0(68)]", views: profileImageView)
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addSubview(dividerView)
        addConstraintWithFormat("H:|-10-[v0]-10-|", views: dividerView)
        addConstraintWithFormat("V:[v0(1)]|", views: dividerView)
    }
    
    private func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)
        
        addConstraintWithFormat("H:|-90-[v0]|", views: containerView)
        addConstraintWithFormat("V:[v0(50)]", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        addConstraintWithFormat("H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        
        containerView.addSubview(messageLabel)
        addConstraintWithFormat("H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)

        addConstraintWithFormat("V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        addConstraintWithFormat("V:|[v0(24)]", views: timeLabel)
        addConstraintWithFormat("V:[v0(20)]|", views: hasReadImageView)
        
        
    }
}

extension UIView {
    func addConstraintWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}


class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
//        backgroundColor = .blue
    }
}

