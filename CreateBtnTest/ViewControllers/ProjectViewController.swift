import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProjectViewController: UIViewController {

    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var createTimeButton: UIButton!
    // timeDataの要素を入れる用配列
    var projectTime = [TimeModel]()
    var postTime = [String]()
    
    var projectTitle: String!
    var projectId: String!
    
    var firebase = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchTimeDataFromFirestore()
    }
    
    private func setUpView() {
        navigationItem.title = projectTitle
        createTimeButton.layer.cornerRadius = 10
        
        timeTableView.delegate = self
        timeTableView.dataSource = self
        }
    
    @IBAction func createTimeBtnTapped(_ sender: Any) {
        UserDefaults.standard.set(projectTitle, forKey: "projectTitle")
        UserDefaults.standard.set(projectId, forKey: "projectId")
    }
    
    private func fetchTimeDataFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        firebase.collection("user").document(userId).collection("project").document(projectId).collection("timer").addSnapshotListener { (snapshots, err) in
            if err != nil {
                print("Firebaseから情報受け取りに失敗しました")
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let timeId = documentChange.document.documentID
                    let timeObject = documentChange.document.data() as [String:AnyObject]
                    let work = timeObject["work"]
                    let rest = timeObject["rest"]
                    let repeatCount = timeObject["repeat"]
                    
                    let timer = TimeModel(workTime: work as? String, restTime: rest as? String, repeatTime: repeatCount  as? String, timeId: timeId)
                    self.projectTime.append(timer)
                    
                    self.timeTableView.reloadData()
                    
                case .modified, .removed:
                    print("Nothing To Do")
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension ProjectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TimeTableViewCell
        let time: TimeModel
        time = projectTime[indexPath.row]
        cell.timeLabel.text = "\(time.workTime!)分×\(time.restTime!)分　\( time.repeatTime!)回"
        return cell
    }
    
    // セルタップ時に次の画面へ遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let time: TimeModel
        time = projectTime[indexPath.row]
        postTime.append(time.workTime!)
        postTime.append(time.restTime!)
        postTime.append(time.repeatTime!)
        
        // セルの選択を解除
        timeTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "GoNext", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoNext" {
            let nextVC = segue.destination as! TimerViewController
            nextVC.repeatTime = postTime
            postTime.removeAll()
        }
    }
}

class TimeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timeView.layer.cornerRadius = 10
        // セル選択時の色を変更
        selectedBackgroundView = makeSelectedBackgroundView()
    }
    // セル選択時の背景色をを白にする処理
    private func makeSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
