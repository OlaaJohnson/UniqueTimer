//
//  ViewController.swift
//

import UIKit
import AVFoundation
import UserNotifications

class UniqueTimerViewController: UIViewController
{
    @IBOutlet weak var timerPicker: UIPickerView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var variousLabel: UIButton!
    @IBOutlet weak var cancelLabel: UIButton!
    @IBOutlet weak var viewOfPicker: UIView!
    
    var center: UNUserNotificationCenter!
    var setTime: Int = 0
    var timer = Timer()
    var isTimerRunning = false
    var isTimerCanceled = true
    
    var hours = UILabel()
    var minutes = UILabel()
    var seconds = UILabel()
    var pwdIsSet: Bool!
    
    // View Load
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Local noti rights
        center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        
        // Picker View delegate
        timerPicker.delegate = self
        timerPicker.dataSource = self
        
        // Hours Minutes
        hours.text = "H"
        minutes.text = "M"
        seconds.text = "S"
        
        let labels = [0:hours, 1:minutes, 2:seconds]
        
        // Fixed letter of picker view
        timerPicker.setPickerLabels(labels: labels, containedView: viewOfPicker)
        cancelLabel.isEnabled = false
        
        // Background work
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(noti:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // Immediately before the view
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Whether password is set
        if UserDefaults.init(suiteName: "group.com.olajohnnsonkeepmeetwithcontact.app")?.bool(forKey: "pwdIsSet") == nil
        {
            pwdIsSet = false
        } else
        {
            pwdIsSet = (UserDefaults.init(suiteName: "group.com.olajohnnsonkeepmeetwithcontact.app")?.bool(forKey: "pwdIsSet"))!
        }        
        
        // 비밀번호 설명 알림창
        let alert = UIAlertController(title: "Set password", message: "\nThe number of the timer is the password\n\n" + "1. Non-entry ▶ Start button ▶ Completed setup\n" + "2. Non-entry ▶ Start button ▶ Start using", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
        if !pwdIsSet { self.present(alert, animated: true) }
    }
    
    
    // 타이머 실행
    func runTimer()
    {
        timerLabel.text = timeString(time: TimeInterval(self.setTime))
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            if self.setTime < 1
            {
                self.cancelAction(Any.self)
            } else
            {
                self.setTime = self.setTime - 1
                self.timerLabel.text = self.timeString(time: TimeInterval(self.setTime))
            }
        }
        
        isTimerRunning = true
    }
    
    // 타이머 스트링
    func timeString(time:TimeInterval) -> String
    {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format:"%02i : %02i : %02i", hours, minutes, seconds)
    }
    
    // 백그라운드 진입
    @objc func didEnterBackground(noti: Notification)
    {
        // setTime 이후 알림
        if isTimerRunning && !isTimerCanceled
        {
            // 앱 종료 시간 저장
            UserDefaults.standard.set(Date(), forKey: "savedTime")
            
            // 앱 타이머 정지
            timer.invalidate()
            
            // 로컬 노티 울림
            Bundle.main.path(forResource: "Radar", ofType: "mp3")
            
            let content = UNMutableNotificationContent()
            content.body = "Timer has ended"
            content.sound = UNNotificationSound(named: convertToUNNotificationSoundName("Radar.mp3"))
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(setTime), repeats: false)
            let request = UNNotificationRequest(identifier: "TimerNotification", content: content, trigger: trigger)
            
            center.add(request)
        }
    }
    
    // 포그라운드 진입 직전
    @objc func willEnterForeground(noti: Notification)
    {
        if isTimerRunning && !isTimerCanceled
        {
            // 앱 종료 & 실행 시간 비교
            if let savedDate = UserDefaults.standard.object(forKey: "savedTime") as? Date
            {
                // 실행 시간 빼기 종료 시간
                let time = Calendar.current.dateComponents([.second], from: savedDate, to: Date())
                let interval = setTime - time.second!
                
                // 인터벌에 따른 코드 실행
                if interval < 1
                {
                    self.cancelAction(Any.self)
                } else
                {
                    setTime = setTime - time.second!
                }
            }
            
            // 타이머 실행
            runTimer()
        }
    }
    
    // 취소 버튼
    @IBAction func cancelAction(_ sender: Any)
    {
        // 취소 코드
        setTime = 0
        
        timerPicker.alpha = 1
        timerLabel.alpha = 0
        
        timer.invalidate()
        timerLabel.text = timeString(time: TimeInterval(setTime))
        
        variousLabel.setTitle("start", for: .normal)
        isTimerRunning = false
        isTimerCanceled = true
        cancelLabel.isEnabled = false
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // 시작 정지 재개 버튼
    @IBAction func variousAction(_ sender: Any)
    {
        if variousLabel.titleLabel?.text == "start" && isTimerCanceled
        {
            // 비밀 행동
            let password = "\(timerPicker.selectedRow(inComponent: 0))" + "\(timerPicker.selectedRow(inComponent: 1))" + "\(timerPicker.selectedRow(inComponent: 2))"
            
            if UserDefaults.init(suiteName: "group.com.olajohnnsonkeepmeetwithcontact.app")?.bool(forKey: "pwdIsSet") == nil
            {
                pwdIsSet = false
            } else
            {
                pwdIsSet = (UserDefaults.init(suiteName: "group.com.olajohnnsonkeepmeetwithcontact.app")?.bool(forKey: "pwdIsSet"))!
            }
            
            if !pwdIsSet
            {
                UserDefaults.init(suiteName: "group.com.olajohnnsonkeepmeetwithcontact.app")?.set(password, forKey: "password")
                UserDefaults.init(suiteName: "group.com.olajohnnsonkeepmeetwithcontact.app")?.set(true, forKey: "pwdIsSet")
                
                // 설정된 비밀번호 확인창
                let alert = UIAlertController(title: "Completed setup", message: "password : " + "\(timerPicker.selectedRow(inComponent: 0)) " + "\(timerPicker.selectedRow(inComponent: 1)) " + "\(timerPicker.selectedRow(inComponent: 2))", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            } else if pwdIsSet
            {
                
                if password == UserDefaults.init(suiteName: "group.com.olajohnnsonkeepmeetwithcontact.app")?.string(forKey: "password")
                {
                    performSegue(withIdentifier: "secretSegue", sender: self)
                }
            }
    
            // 타이머 시작 행동
            setTime = timerPicker.selectedRow(inComponent: 0) * 3600 + timerPicker.selectedRow(inComponent: 1) * 60 + timerPicker.selectedRow(inComponent: 2)
            
            timerPicker.alpha = 0
            timerLabel.alpha = 1
            
            if isTimerRunning == false
            {
                runTimer()
            }
            
            variousLabel.setTitle("stop", for: .normal)
            isTimerCanceled = false
            cancelLabel.isEnabled = true
            
            return
        } else if variousLabel.titleLabel?.text == "stop" && !isTimerCanceled
        {
            timer.invalidate()
            
            variousLabel.setTitle("Resume", for: .normal)
            isTimerRunning = false
            
            return
        } else if variousLabel.titleLabel?.text == "Resume" && !isTimerCanceled
        {
            if isTimerRunning == false
            {
                runTimer()
            }
            
            variousLabel.setTitle("stop", for: .normal)
            
            return
        }
    }
}

extension UniqueTimerViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    // 줄의 개수
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 3
    }
    
    // 각 줄에 대한 요소 개수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if component == 0
        {
            return 24
        } else
        {
            return 60
        }
    }
    
    // 피커뷰 요소 커스텀
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let label = UILabel()
        label.text = String(row)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 25)
        
        return label
    }
}

extension UIPickerView
{
    // 고정된 피커뷰 글자
    func setPickerLabels(labels: [Int:UILabel], containedView: UIView)
    {
        let fontSize:CGFloat = 20
        let labelWidth:CGFloat = containedView.bounds.width / CGFloat(self.numberOfComponents)
        let x:CGFloat = self.frame.origin.x + 35
        let y:CGFloat = (self.frame.size.height / 2) - (fontSize / 2)
        
        for i in 0...self.numberOfComponents
        {
            if let label = labels[i]
            {
                if self.subviews.contains(label)
                {
                    label.removeFromSuperview()
                }
                
                label.frame = CGRect(x: x + labelWidth * CGFloat(i), y: y, width: labelWidth, height: fontSize)
                label.font = UIFont.boldSystemFont(ofSize: fontSize)
                label.backgroundColor = .clear
                label.textAlignment = .center
                
                self.addSubview(label)
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUNNotificationSoundName(_ input: String) -> UNNotificationSoundName {
	return UNNotificationSoundName(rawValue: input)
}
