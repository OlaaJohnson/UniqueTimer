//
//  DetailViewController.swift


import UIKit
import CoreData
import SDWebImage

class DetailViewController: UIViewController
{    
    @IBOutlet weak var imageView: UIImageView!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchedRC: NSFetchedResultsController<FullRes>!
    var fetchedRCThumb: NSFetchedResultsController<Thumbnail>!
    var indexPath: IndexPath!
    var visibleImage: UIImage!
    
    var collectionView: UICollectionView!
    var imgArray = [UIImage]()
    var topPadding: CGFloat!
    var safeAreaHeight: CGFloat!
    
    let loadingQueue = OperationQueue()
    
    // 뷰 로드 후
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 준비
        refresh()        
        
        // 안전 구역 설정
        if #available(iOS 11.0, *)
        {
            let window = UIApplication.shared.keyWindow
            topPadding = window?.safeAreaInsets.top
            let bottomPadding = window?.safeAreaInsets.bottom
            safeAreaHeight = self.view.frame.height - (topPadding! + bottomPadding!)
        } else {
            topPadding = topLayoutGuide.length
            let bottomPadding = bottomLayoutGuide.length
            safeAreaHeight = self.view.frame.height - (topPadding + bottomPadding)
        }
        
        // 사진 슬라이드
        self.view.backgroundColor = UIColor.white
        let bar = topPadding + safeAreaHeight * 0.0875
        let size = CGRect(x: 0, y: bar, width: self.view.frame.width, height: safeAreaHeight * 0.825)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: size, collectionViewLayout: layout)
        collectionView.delegate=self
        collectionView.dataSource=self
        collectionView.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: "DetailCell")
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        
        self.view.addSubview(collectionView)

        collectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
    }
    
    // 리프레쉬
    func refresh()
    {
        // 풀화질
        let request = FullRes.fetchRequest() as NSFetchRequest<FullRes>
        let sort = NSSortDescriptor(key: #keyPath(FullRes.thumbnail.id), ascending: true)
        
        request.sortDescriptors = [sort]
        
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // 썸네일
        let requestThumb = Thumbnail.fetchRequest() as NSFetchRequest<Thumbnail>
        let sortThumb = NSSortDescriptor(key: #keyPath(Thumbnail.id), ascending: true)
        
        requestThumb.sortDescriptors = [sortThumb]
        
        do {
            fetchedRCThumb = NSFetchedResultsController(fetchRequest: requestThumb, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRCThumb.performFetch()
        } catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

extension DetailViewController
{
    // 완료 버튼
    @IBAction func cancelButton(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    // 공유 버튼
    @IBAction func shareButton(_ sender: Any)
    {
        let fullRes = fetchedRC.object(at: collectionView.indexPathsForVisibleItems.first!)

        if let data = fullRes.imageData as Data?
        {
            let image = UIImage(data: data) as Any
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view

            present(activityVC, animated: true, completion: nil)
        }
    }
    
    // 삭제 버튼
    @IBAction func trashButton(_ sender: Any)
    {
        let fullRes = fetchedRC.object(at: collectionView.indexPathsForVisibleItems.first!)
        context.delete(fullRes)
        
        let thumbnail = fetchedRCThumb.object(at: collectionView.indexPathsForVisibleItems.first!)
        context.delete(thumbnail)
        
        appDelegate.saveContext()
        refresh()
        dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return fetchedRC.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCollectionViewCell
        
        // 풀화질 표시
        let fullRes = fetchedRC.object(at: indexPath)
        
        if let data = fullRes.imageData as Data?
        {
            cell.imageView?.sd_setImage(with: nil, placeholderImage: UIImage(data: data), options: .init(rawValue: 255), completed: nil)
            
        } else
        {
            
        }
        
        // 현재 인덱스 입력
        self.indexPath = indexPath
        
        return cell
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.itemSize = collectionView.frame.size
        flowLayout.invalidateLayout()
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = collectionView.contentOffset
        let width  = collectionView.bounds.size.width
        
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        collectionView.setContentOffset(newOffset, animated: false)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.collectionView.reloadData()
            
            self.collectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }
}

extension DetailViewController: UICollectionViewDataSourcePrefetching
{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath])
    {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath])
    {
        
    }
}
