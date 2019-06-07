//
//  AddContactViewController.swift


import UIKit
import CoreData

class AddContactViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    
    var fetchedRC: NSFetchedResultsController<Contact>!    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).contactContainer.viewContext
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
    // 뷰 로드
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 키보드 내리기
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddContactViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        // 키보드가 가리면 스크롤해주기
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 키보드로 다음 텍스필드로 넘어가기
        nameTextField.delegate = self
        nameTextField.tag = 0
        numberTextField.delegate = self
        numberTextField.tag = 1
        emailTextField.delegate = self
        emailTextField.tag = 2
        noteTextField.delegate = self
        noteTextField.tag = 3
    }
    
    // 키보드로 다음 텍스필드로 넘어가기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField
        {
            nextField.becomeFirstResponder()
        } else
        {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    // 뷰 보이기 직전
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        refresh()
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
    
    // 키보드 내리기
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    // 키보드가 가리면 스크롤해주기
    @objc func keyboardWillShow(notification: Notification)
    {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        
        scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
    }
    
    @objc func keyboardWillHide(notification: Notification)
    {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    
    // 저장 버튼
    @IBAction func saveAction(_ sender: Any)
    {
        // 연락처에 저장
        let contact = Contact(entity: Contact.entity(), insertInto: context)
        contact.name = nameTextField.text
        contact.number = numberTextField.text
        contact.email = emailTextField.text
        contact.note = noteTextField.text
        
        // 저장
        appDelegate.saveContact()
        refresh()
        
        // 뒤로가기
        navigationController?.popViewController(animated: true)
    }
}
