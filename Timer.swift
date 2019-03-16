/// GCD定时器倒计时⏳
///   - timeInterval: 循环间隔时间
///   - repeatCount: 重复次数
///   - handler: 循环事件, 闭包参数： 1. timer， 2. 剩余执行次数
public func DispatchTimer(timeInterval: Double, repeatCount:Int, handler:@escaping (DispatchSourceTimer?, Int)->()) {
    if repeatCount <= 0 {
        return
    }
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    var count = repeatCount
    timer.schedule(wallDeadline: .now(), repeating: timeInterval)
    timer.setEventHandler(handler: {
        count -= 1
        DispatchQueue.main.async {
            handler(timer, count)
        }
        if count == 0 {
            timer.cancel()
        }
    })
    timer.resume()
}
