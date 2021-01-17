import UIKit
import FirebaseFirestore
import FirebaseAuth
import Charts

class GraphViewController: UIViewController {
    
    @IBOutlet weak var graphChartView: PieChartView!
    var projectTitle: String?
    var projectId: String!
    var graphData = ["達成", "未達成"]
    var graphNumber = [Double]()
    var Achievement: Double?
    var notAchieved: Double?
    var titleDatas = [String]()
    
    private var firebase = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView() {
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
}
