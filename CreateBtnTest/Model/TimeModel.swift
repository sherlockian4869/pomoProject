class TimeModel {
    
    var workTime: String?
    var restTime: String?
    var repeatTime: String?
    var timeId: String?
    
    init(workTime: String?, restTime: String?, repeatTime: String?, timeId: String?) {
        self.workTime = workTime;
        self.restTime = restTime;
        self.repeatTime = repeatTime;
        self.timeId = timeId;
    }
}
