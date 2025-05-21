//
//  ReportBusynessView.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI

struct ReportBusynessView: View {
    @Environment(\.dismiss) var dismiss
    let park: DogPark

    @State private var selectedBusyness: BusynessLevel = .moderate
    @State private var comment: String = ""
    @State private var dogsInGroup: Int = 1

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("How busy is \(park.name)?").foregroundColor(AppColors.textSecondary)) {
                    Picker("Select Busyness", selection: $selectedBusyness) {
                        ForEach(BusynessLevel.allCases) { level in
                            HStack {
                                Image(systemName: level.icon)
                                    .foregroundColor(level.color)
                                Text(level.rawValue)
                            }
                            .tag(level) // Crucial for Picker to identify items
                        }
                    }
                    .foregroundColor(AppColors.textPrimary)
                    // For debugging picker:
                    // Text("Selected: \(selectedBusyness.rawValue)")
                }
                Section(header: Text("Optional Details").foregroundColor(AppColors.textSecondary)) {
                    TextField("Add a comment...", text: $comment).foregroundColor(AppColors.textPrimary)
                    Stepper("Dogs in your group: \(dogsInGroup)", value: $dogsInGroup, in: 1...10).foregroundColor(AppColors.textPrimary)
                }
                Button {
                    let newReport = UserReport(
                        reportedBusyness: selectedBusyness,
                        comment: comment.isEmpty ? nil : comment,
                        timestamp: Date(),
                        dogsInGroup: dogsInGroup
                    )
                    print("New Report Submitted for \(park.name): \(newReport)") // Placeholder for actual submission
                    dismiss()
                } label: {
                    Text("Submit Report")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fontWeight(.semibold)
                }
                .tint(AppColors.sunshineYellow)
            }
            .background(AppColors.appBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Report Busyness")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(AppColors.parkGreen)
                }
            }
        }
    }
}

struct ReportBusynessView_Previews: PreviewProvider {
    static var previews: some View {
        ReportBusynessView(park: MockData.shared.sampleParks[0])
    }
}
