import UIKit
import FirebaseFirestore
import FirebaseAuth

class ReportViewController: UIViewController {

    @IBOutlet weak var reportTableView: UITableView!
    private var titleData = [ProjectModel]()
    var titleName: String?
    var titleId: String?
    private var firebase = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        fetchProjectFromFireStore()
    }

    private func setUpView() {
        reportTableView.delegate = self
        reportTableView.dataSource = self
        
        navigationItem.title = "データ"
    }
    
    // CreateViewControllerで追加されたtitleを配列に追加後UserDefaultsに格納
    private func fetchProjectFromFireStore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        firebase.collection("user").document(userId).collection("project").addSnapshotListener { (snapshots, err) in
            if err != nil {
                print("データ取得に失敗しました")
            }
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let titleId = documentChange.document.documentID
                    let proObject = documentChange.document.data() as [String:AnyObject]
                    let projectTitle = proObject["project_Name"]
                    
                    let project = ProjectModel(projectId: titleId, projectTitle: projectTitle as? String)
                    self.titleData.append(project)
                    
                    self.reportTableView.reloadData()
                    
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

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ReportTableViewCell
        let pro: ProjectModel
        pro = titleData[indexPath.row]
        cell.reportLabel.text = pro.projectTitle! + "　レポート"
        return cell
    }
    
    // セルタップ時に次の画面へ遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pro: ProjectModel
        pro = titleData[indexPath.row]
        titleName = pro.projectTitle
        titleId = pro.projectId
        // セルの選択を解除
        reportTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "NextData", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextData" {
            let nextVC = segue.destination as! GraphViewController
            nextVC.projectTitle = titleName
            nextVC.projectId = titleId
        }
    }
}

class ReportTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var reportLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reportView.layer.cornerRadius = 10
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
