import SwiftUI
import AlarmKit

@available(iOS 26.0, *)
struct AlarmListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var alarmManager = BurnedAlarmManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    if alarmManager.hasAlarms {
                        List {
                            ForEach(Array(alarmManager.alarmsMap.values), id: \.0.id) { (alarm, type, characterName) in
                                AlarmRowView(alarm: alarm, type: type, characterName: characterName) {
                                    alarmManager.unscheduleAlarm(with: alarm.id)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.black)
                    } else {
                        ContentUnavailableView(
                            "No Alarms Set",
                            systemImage: "alarm",
                            description: Text("Set up alarms to get motivated by your character")
                        )
                        .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("My Alarms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .onAppear {
            alarmManager.fetchAlarms()
        }
    }
}

@available(iOS 26.0, *)
struct AlarmRowView: View {
    let alarm: Alarm
    let type: AlarmType
    let characterName: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Character image with type gradient border
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: type.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                // Character image
                if let character = Character.allCharacters.first(where: { $0.name == characterName }) {
                    Image(character.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                } else {
                    // Fallback to type icon if character not found
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(type.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(type.emoji)
                        .font(.body)
                }
                
                HStack {
                    Text("with")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(characterName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    // Add character emoji
                    if let character = Character.allCharacters.first(where: { $0.name == characterName }) {
                        Text(character.emoji)
                            .font(.caption)
                    }
                }
                
                if let time = alarm.alertingTime {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text(time, style: .time)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Status badge
            Text(statusText)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(statusColor.opacity(0.8))
                )
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .background(Color.black)
    }
    
    private var statusText: String {
        switch alarm.state {
        case .scheduled: return "Active"
        case .countdown: return "Running"
        case .paused: return "Paused"
        case .alerting: return "Alert"
        @unknown default: return "Unknown"
        }
    }
    
    private var statusColor: Color {
        switch alarm.state {
        case .scheduled: return .green
        case .countdown: return .blue
        case .paused: return .yellow
        case .alerting: return .red
        @unknown default: return .gray
        }
    }
}

@available(iOS 26.0, *)
extension Alarm {
    var alertingTime: Date? {
        guard let schedule else { return nil }
        
        switch schedule {
        case .fixed(let date):
            return date
        case .relative(let relative):
            var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
            components.hour = relative.time.hour
            components.minute = relative.time.minute
            return Calendar.current.date(from: components)
        @unknown default:
            return nil
        }
    }
}

 
