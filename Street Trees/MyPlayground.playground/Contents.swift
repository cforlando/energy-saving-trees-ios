//: Playground - noun: a place where people can play

import UIKit

let data = ["Field1":"test12","Field2":"test22","Field3":"1234567890"]
let data2 = ["Field4":"test12","Field5":"test22","Field6":"1234567890"]

func +=<K: Hashable, V>(inout lhs: [K: V], rhs: [K: V]) {
    lhs = lhs + rhs
}

func +<K: Hashable, V>(lhs: [K: V], rhs: [K: V]) -> [K: V] {
    var completeDictionary = lhs
    
    for (key, value) in rhs {
        completeDictionary[key] = value
    }
    
    return completeDictionary
}

let data3 = data + data2

data