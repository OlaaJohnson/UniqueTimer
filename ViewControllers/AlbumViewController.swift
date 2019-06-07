//
//  AlbumViewController.swift


import UIKit
import CoreData
import SDWebImage

class AlbumViewController: UIViewController
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    let date : Double = NSDate().timeIntervalSince1970
    var fetchedRC: NSFetchedResultsController<Thumbnail>!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // 뷰 로드
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
        
        // 이미지 피커 델리게이트
        imagePicker.delegate = self
        
        // 콜렉션 뷰 셀 사이즈 조정
        let width = (view.frame.size.width - 7.5) / 4
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    // 뷰 보이기 직전
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        refresh()
        collectionView.reloadData()
    }
    
    // 리프레쉬
    func refresh()
    {
        // 썸네일
        let request = Thumbnail.fetchRequest() as NSFetchRequest<Thumbnail>
        
        let sort = NSSortDescriptor(key: #keyPath(Thumbnail.id), ascending: true)
        
        request.sortDescriptors = [sort]
        
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // 편집 버튼 (플러스 버튼)
    @IBAction func editAction(_ sender: Any)
    {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    // 셀의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return fetchedRC.fetchedObjects?.count ?? 0
    }
    
    // 각 셀의 표현
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell
        
        // 썸네일 표시
        let thumbnail = fetchedRC.object(at: indexPath)
        
        if let data = thumbnail.imageData as Data?
        {
             cell.imageView?.sd_setImage(with: nil, placeholderImage: UIImage(data: data), options: .init(rawValue: 255), completed: nil)
        } else
        {
            
        }
        
        return cell
    }    
    
    // 셀 선택시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {        
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
        
        detailVC.indexPath = indexPath
        
        self.present(detailVC, animated: true, completion: nil)
    }
}

extension AlbumViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    // 이미지 선택시
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        // 코어 데이터에 선택 이미지 저장
        let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        // 썸네일에 저장
        let thumbnail = Thumbnail(entity: Thumbnail.entity(), insertInto: context)
        let thumb = pickedImage.scale(toSize: CGSize(width: 75, height: 75))
        thumbnail.imageData = thumb.pngData() as NSData?
        thumbnail.id = date
        
        // 풀화질 저장
        let fullRes = FullRes(entity: FullRes.entity(), insertInto: self.context)
        let full = pickedImage.scale(toSize: CGSize(width: 250, height: 250))
        fullRes.imageData = full.pngData() as NSData?
        
        // 저장
        appDelegate.saveContext()
        refresh()
        
        // 닫기
        dismiss(animated: true, completion: nil)
    }
    
    // 이미지 선택 안할시
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
