import SwiftUI

struct HabitStatusIcon: View {
    let isCompleted: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.green : Color.red)
                .frame(width: 20, height: 20)
            
            Image(systemName: isCompleted ? "checkmark" : "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

