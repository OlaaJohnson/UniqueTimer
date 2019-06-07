//
//  ContactsViewController.swift


import UIKit
import CoreData

class ContactsViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    var fetchedRC: NSFetchedResultsController<Contact>!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).contactContainer.viewContext

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 네비게이션바 큰 타이틀
        if #available(iOS 11.0, *)
        {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else
        {
            print("need iOS 11.0 or higher")
        }
    }
    
    // 뷰 보이기 직전
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        refresh()
        tableView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "contactSegue"
        {
            let contactVC = segue.destination as! ContactViewController
            contactVC.indexPath = tableView.indexPathForSelectedRow
        }
    }
    
    @IBAction func addContact(_ sender: Any)
    {
        
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return fetchedRC.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // 셀 지정
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath)
        
        // 연락처 표시
        let contact = fetchedRC.object(at: indexPath)        
        cell.textLabel?.text = contact.name
        
        return cell
    }
    
    // 테이블뷰 삭제 작업
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            // 코어 데이터에서 삭제
            let contact = fetchedRC.object(at: indexPath)
            context.delete(contact)
            appDelegate.saveContact()
            refresh()
            
            // 테이블 뷰에서 삭제
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
