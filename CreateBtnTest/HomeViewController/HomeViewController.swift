import UIKit
import FirebaseFirestore
import FirebaseAuth

class HomeViewController: UIViewController {
    
    @IBOutlet weak var proTableView: UITableView!
    @IBOutlet weak var createButton: UIButton!
    private var titleData = [ProjectModel]()
    var titleName: String?
    var titleId: String?
    private var firebase = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        confirmLoggedInUser()
        fetchProjectFromFireStore()
    }
    
    private func setUpView() {
        print("view")
        createButton.layer.cornerRadius = 10
        proTableView.delegate = self
        proTableView.dataSource = self
        navigationItem.title = "タイマー"
        
        let logoutBarButton = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(tappedNavLeftBarButton))
        navigationItem.rightBarButtonItem = logoutBarButton

    }
    
    @objc private func tappedNavLeftBarButton() {
        do {
            try Auth.auth().signOut()
            pushLoginViewController()
        } catch {
            print("ログアウトに失敗しました")
        }
    }
    
    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            pushLoginViewController()
        }
    }
    
    private func pushLoginViewController() {
        let storyboard = UIStoryboard(name: "SignUpView", bundle: nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let nav = UINavigationController(rootViewController: signUpViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    // CreateViewControllerで追加されたtitleを配列に追加後UserDefaultsに格納
    private func fetchProjectFromFireStore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        print(userId)
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
                    
                    self.proTableView.reloadData()
                    
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

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProjectTableViewCell
        let pro: ProjectModel
        pro = titleData[indexPath.row]
        cell.projectTitleLabel.text = pro.projectTitle
        return cell
    }
    
    // セルタップ時に次の画面へ遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pro: ProjectModel
        pro = titleData[indexPath.row]
        titleName = pro.projectTitle
        titleId = pro.projectId
        // セルの選択を解除
        proTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "NextView", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextView" {
            let nextVC = segue.destination as! ProjectViewController
            nextVC.projectTitle = titleName
            nextVC.projectId = titleId
        }
    }
    // TableViewのCellを消す
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }

    //スワイプしたセルを削除　※arrayNameは変数名に変更してください
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//            titleData.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
//        }
//    }
}

class ProjectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleView.layer.cornerRadius = 10
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
