//
//  SettingsViewController.swift


import UIKit

class SettingsViewController: UIViewController
{
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
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // 셀 지정
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)

        // 네비게이션바 큰 타이틀
        if #available(iOS 11.0, *)
        {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else
        {
            print("need iOS 11.0 or higher")
        }        // 셀에 앨범 이름 지정
        if indexPath.row == 0
        {
            cell.textLabel?.text = "Change Password"
        } else if indexPath.row == 1
        {
            cell.textLabel?.text = "App Reviews"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // 설정 옵션 눌렀을 때
        if indexPath.row == 0
        {
            // 비밀번호 변경
            UserDefaults.init(suiteName: "group.com.olajohnnsonkeepmeetwithcontact.app")?.set(false, forKey: "pwdIsSet")
            
            // 초기 화면으로 돌아가기
            dismiss(animated: true, completion: nil)
            
        } else if indexPath.row == 1
        {
            guard let url = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1467331614?mt=8"),
                UIApplication.shared.canOpenURL(url) else {
                    return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            // 앱 리뷰
//            let url = URL(string: "itms-apps://itunes.apple.com/app/id1422471266")!
//            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
