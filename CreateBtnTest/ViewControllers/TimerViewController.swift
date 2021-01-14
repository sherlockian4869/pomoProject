import UIKit

class TimerViewController: UIViewController {

    var repeatTime = [String]()
    private var workTimer: Timer?
    private var restTimer: Timer?
    private var count = 0
    private var workCounter = 0
    private var elapsedTime: TimeInterval = 0.0
    private var workTime: Int?
    private var restTime: Int?
    private var repeatCount: Int?
    
    @IBOutlet weak var workOrRestLabel: UILabel!
    @IBOutlet weak var pomoTimerLabel: UILabel!
    @IBOutlet weak var pomoStartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }
    
    private func setUpView() {
        // String型の配列をInt型へ変更
        let compactMapped = repeatTime.compactMap { value in
            Int(value)
        }
        print("compactMapped: \(compactMapped)")
        
        let leftButton = UIBarButtonItem(title: "戻る", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TimerViewController.goBackButton))
        self.navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem(title: "終了", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TimerViewController.finishButton))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        pomoTimerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .medium)
        pomoStartButton.layer.cornerRadius = 34
        workTime = compactMapped[0]
        restTime = compactMapped[1]
        repeatCount = compactMapped[2]
    }
    
    @objc private func goBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func finishButton() {
        let alert: UIAlertController = UIAlertController(title: "終了", message: "本当に終了しますか？", preferredStyle:  UIAlertController.Style.alert)
        
        let finishAction: UIAlertAction = UIAlertAction(title: "終了", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.elapsedTime = 0
            self.workTimer?.invalidate()
            self.restTimer?.invalidate()
            self.tabBarController!.tabBar.items![0].isEnabled = true
            self.tabBarController!.tabBar.items![1].isEnabled = true
            self.navigationController?.popToRootViewController(animated: true)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(finishAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pomoStartBtnTapped(_ sender: Any) {
        setPomodoroTimer()
    }
    
    private func setPomodoroTimer() {
        // アラート表示
        let alert: UIAlertController = UIAlertController(title: "スタートしますか？", message: "スタートすると終わるまで変更できません", preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            while self.count < self.repeatCount! {
                if self.elapsedTime == 0.0 {
                    self.workStart()
                    self.count += 1
                } else {
                    return
                }
            }
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func workStart() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.tabBarController!.tabBar.items![0].isEnabled = false
        self.tabBarController!.tabBar.items![1].isEnabled = false
        self.pomoStartButton.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        elapsedTime = TimeInterval(workTime! * 60)
        print(elapsedTime)
        workTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerViewController.workHandleTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func workHandleTimer() {
        workOrRestLabel.text = "作業"
        elapsedTime -= workTimer!.timeInterval
        if elapsedTime == 0 {
            workTimer?.invalidate()
            elapsedTime = TimeInterval(restTime! * 60)
            restTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerViewController.restHandleTimer), userInfo: nil, repeats: true)
        }
        let second = Int(self.elapsedTime) % 60
        let minutes = Int(self.elapsedTime) % 3600 / 60
        self.pomoTimerLabel.text = String(format: "%02d:%02d", minutes, second)
    }
    
    @objc private func restHandleTimer() {
        workOrRestLabel.text = "休憩"
        elapsedTime -= restTimer!.timeInterval
        let second = Int(self.elapsedTime) % 60
        let minutes = Int(self.elapsedTime) % 3600 / 60
        self.pomoTimerLabel.text = String(format: "%02d:%02d", minutes, second)
        if elapsedTime == 0 {
            restTimer?.invalidate()
            elapsedTime = 0
            workCounter += 1
            if workCounter == repeatCount {
                navigationItem.leftBarButtonItem?.isEnabled = true
                workOrRestLabel.text = "終了"
                
                // アラート表示
                let alert: UIAlertController = UIAlertController(title: "終了しますか？", message: "終了しますか？それとも繰り返しますか？", preferredStyle:  UIAlertController.Style.alert)
                
                let finishAction: UIAlertAction = UIAlertAction(title: "終了", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                })
                self.tabBarController!.tabBar.items![0].isEnabled = true
                self.tabBarController!.tabBar.items![1].isEnabled = true
                let repeatAction: UIAlertAction = UIAlertAction(title: "繰り返す", style: UIAlertAction.Style.cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    while self.count < self.repeatCount! {
                        self.workStart()
                        print(self.count)
                        self.count += 1
                    }
                    self.pomoStartButton.isEnabled = false
                    self.navigationItem.leftBarButtonItem?.isEnabled = false
                })
                alert.addAction(repeatAction)
                alert.addAction(finishAction)
                present(alert, animated: true, completion: nil)
            } else {
                workStart()
            }
        }
    }
    
}
