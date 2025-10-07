//
//  MetricsModel.swift
//  Burned
//
//  Created by Raghav Sethi on 04/10/25.
//

import Foundation

struct MetricsModel {
    var elapsedTime: TimeInterval = 0
    var heartRate: Double?
    var activeEnergy: Double?
    var distance: Double?
    var speed: Double?
    var supportsDistance: Bool = false
    var supportsSpeed: Bool = false
    
    init(elapsedTime: TimeInterval = 0, heartRate: Double? = nil, activeEnergy: Double? = nil, distance: Double? = nil, speed: Double? = nil, supportsDistance: Bool = false, supportsSpeed: Bool = false) {
        self.elapsedTime = elapsedTime
        self.heartRate = heartRate
        self.activeEnergy = activeEnergy
        self.distance = distance
        self.speed = speed
        self.supportsDistance = supportsDistance
        self.supportsSpeed = supportsSpeed
    }
    
    func getHeartRate() -> String {
        guard let heartRate = heartRate else { return "--" }
        return "\(Int(heartRate))"
    }
    
    func getActiveEnergy() -> String {
        guard let activeEnergy = activeEnergy else { return "--" }
        return "\(Int(activeEnergy))"
    }
    
    func getDistance() -> String {
        guard let distance = distance else { return "--" }
        let distanceInKm = distance / 1000
        return String(format: "%.2f km", distanceInKm)
    }
    
    func getSpeed() -> String {
        guard let speed = speed else { return "--" }
        let speedInKmH = speed * 3.6
        return String(format: "%.1f km/h", speedInKmH)
    }
    
    func getFormattedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) % 3600 / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}