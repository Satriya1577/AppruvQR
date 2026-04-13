//
//  TaskInputSectionView.swift
//  AppruvQR
//
//  Created by Jessica Laurentia Tedja on 13/04/26.
//
import SwiftUI

struct TaskInputSectionView: View {
    @Binding var title: String
    @Binding var notes: String
    @Binding var date: Date?
    @Binding var time: Date?
    @Binding var showDatePicker: Bool
    @Binding var showTimePicker: Bool

    @FocusState.Binding var focusedField: TaskSheetView.Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                TextField("Title", text: $title)
                    .focused($focusedField, equals: .title)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                    .padding(.bottom, 8)

                Divider()

                TextField("Notes", text: $notes)
                    .focused($focusedField, equals: .notes)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)

            VStack(alignment: .leading, spacing: 12) {
                Text("Date & Time")
                    .padding(.top, 6)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        focusedField = nil
                        if date == nil {
                            date = Date()
                        }
                        showDatePicker.toggle()
                        showTimePicker = false
                    } label: {
                        HStack {
                            Image(systemName: "calendar")

                            VStack(alignment: .leading) {
                                Text("Date")

                                if let date {
                                    Text(date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                } else {
                                    Text("This field is required")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)

                    if showDatePicker {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { date ?? Date() },
                                set: { date = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                    }

                    Divider()

                    Button {
                        focusedField = nil
                        if time == nil {
                            time = Date()
                        }
                        showTimePicker.toggle()
                        showDatePicker = false
                    } label: {
                        HStack {
                            Image(systemName: "clock")

                            VStack(alignment: .leading) {
                                Text("Time")

                                if let time {
                                    Text(time, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                } else {
                                    Text("This field is required")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)

                    if showTimePicker {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { time ?? Date() },
                                set: { time = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
            }
        }
    }
}
