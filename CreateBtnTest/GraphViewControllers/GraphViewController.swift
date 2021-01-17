import UIKit
import FirebaseFirestore
import FirebaseAuth
import Charts

class GraphViewController: UIViewController {
    
    @IBOutlet weak var graphChartView: PieChartView!
    @IBOutlet weak var graphTableView: UITableView!
    
    var projectTitle: String?
    var projectId: String!
    var graphData = ["達成", "未達成"]
    var graphNumber = [Double]()
    var Achievement: Double?
    var notAchieved: Double?
    var titleDatas = [String]()
    var projectTime = [TimeModel]()
    
    private var firebase = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchTimeDataFromFirestore()
    }
    
    func setUpView() {
        graphTableView.delegate = self
        graphTableView.dataSource = self
        
        navigationItem.title = "\(projectTitle!)　レポート"
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        firebase.collection("user").document(userId).collection("project").document(projectId).getDocument { (document, err) in
            if err != nil {
                print("データの取得に失敗しました")
            } else {
                let proCounter = document?.data()
                self.Achievement = proCounter?["ProAchievementCount"] as? Double
                self.notAchieved = proCounter?["ProNotAchievementCount"] as? Double
                
                print(self.Achievement!)
                print(self.notAchieved!)
            }
            let number01 = self.Achievement!
            let number02 = self.notAchieved!
            let sum = number01 + number02
            print(sum)
            self.Achievement = number01 / sum * 100
            print("Achievement:",self.Achievement!)
            self.notAchieved = number02 / sum * 100
            print("notAchieved:",self.notAchieved!)
            self.setGraph()
        }
    }
    
    func setGraph() {
        self.graphChartView.centerText = projectTitle
        
        let dataEntries = [
            PieChartDataEntry(value: Achievement!, label: graphData[0]),
            PieChartDataEntry(value: notAchieved!, label: graphData[1]),
        ]
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: projectTitle)
        // グラフの色
        dataSet.colors = ChartColorTemplates.material()
        // グラフのデータの値の色
        dataSet.valueTextColor = UIColor.black
        // グラフのデータのタイトルの色
        dataSet.entryLabelColor = UIColor.black
        
        self.graphChartView.data = PieChartData(dataSet: dataSet)
        
        // データを％表示にする
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1.0
        self.graphChartView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        self.graphChartView.usePercentValuesEnabled = true
        
        view.addSubview(self.graphChartView)
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
                    let timeDocumentId = documentChange.document.documentID
                    let timeObject = documentChange.document.data() as [String:AnyObject]
                    let work = timeObject["work"]
                    let rest = timeObject["rest"]
                    let repeatCount = timeObject["repeat"]
                    
                    let timer = TimeModel(workTime: work as? String, restTime: rest as? String, repeatTime: repeatCount  as? String, timeId: timeDocumentId)
                    self.projectTime.append(timer)
                    
                    self.graphTableView.reloadData()
                    
                case .modified, .removed:
                    print("Nothing To Do")
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension GraphViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = graphTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GraphTableViewCell
        let time: TimeModel
        time = projectTime[indexPath.row]
        cell.graphLabel.text = "\(time.workTime!)分×\(time.restTime!)分　\(time.repeatTime!)回"
        return cell
    }
    
    
}

class GraphTableViewCell: UITableViewCell {
    
    @IBOutlet weak var graphLabel: UILabel!
    @IBOutlet weak var graphView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        graphView.layer.cornerRadius = 10
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
