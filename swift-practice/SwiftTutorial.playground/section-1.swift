import Foundation

func calcAvg(numbers:Int...) -> Double {
    var sum = 0
    var i = 0
    for num in numbers {
        sum += num
        i++
    }
    return (Double);sum/Double(i)
}

var a = calcAvg(1,2,3,4,5,6,7,19)