//
//  ContactViewController.swift


import UIKit
import CoreData
import MessageUI

class ContactViewController: UIViewController
{
    @IBOutlet weak var numberLabel: UIButton!
    @IBOutlet weak var emailLabel: UIButton!
    @IBOutlet weak var noteLabel: UIButton!
    
    @IBOutlet weak var numberStack: UIStackView!    
    @IBOutlet weak var emailStack: UIStackView!
    @IBOutlet weak var noteStack: UIStackView!
    
    var fetchedRC: NSFetchedResultsController<Contact>!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).contactContainer.viewContext
    
    var indexPath: IndexPath!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 리프레쉬
        refresh()
        
        // 값 입력
        let contact = fetchedRC.object(at: indexPath)
        
        self.navigationItem.title = contact.name
        numberLabel.setTitle(contact.number, for: .normal)
        emailLabel.setTitle(contact.email, for: .normal)
        noteLabel.setTitle(contact.note, for: .normal)
        
        // 디자인
        
    }
    
    // 뷰 보이기 직전
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    // 리프레쉬
    func refresh()
    {
        // 연락처
        let request = Contact.fetchRequest() as NSFetchRequest<Contact>
        
        let sort = NSSortDescriptor(key: #keyPath(Contact.name), ascending: true)
        
        request.sortDescriptors = [sort]
        
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // 삭제 버튼 > 편집 버튼으로 변경
    @IBAction func editButton(_ sender: Any)
    {
        // 코어 데이터에서 삭제
        let contact = fetchedRC.object(at: indexPath)
        context.delete(contact)
        appDelegate.saveContact()
        refresh()
        
        // 뒤로가기
        navigationController?.popViewController(animated: true)
    }
}

extension ContactViewController: MFMailComposeViewControllerDelegate
{
    // 전화 걸기
    @IBAction func numberAction(_ sender: Any)
    {
        let number = numberLabel.titleLabel?.text
        number?.makeACall()
    }
    
    // 이메일 보내기
    @IBAction func emailAction(_ sender: Any)
    {
        let email = emailLabel.titleLabel?.text
        sendEmail(email: email!)
    }
    
    // 이메일 보내기 함수
    func sendEmail(email: String)
    {
        if MFMailComposeViewController.canSendMail()
        {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            
            present(mail, animated: true)
        } else
        {
        
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true)
    }
}
