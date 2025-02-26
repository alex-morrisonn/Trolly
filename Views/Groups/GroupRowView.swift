import SwiftUI

struct GroupRowView: View {
    let group: Group
    @EnvironmentObject var groupViewModel: GroupViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(group.name)
                    .font(.headline)
                
                if let description = group.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text("\(group.members.count) members")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if groupViewModel.selectedGroup?.id == group.id {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
