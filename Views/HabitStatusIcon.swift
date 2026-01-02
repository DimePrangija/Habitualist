import SwiftUI

struct HabitStatusIcon: View {
    let isCompleted: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.green : Color.red)
                .frame(width: 28, height: 28)
            
            Image(systemName: isCompleted ? "checkmark" : "xmark")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

