//
//  HomeView.swift
//  AppruvQR
//

import SwiftUI
import SwiftData

// MARK: - 1. Filter Enum
enum FilterTab: String, CaseIterable {
    case primary = "Primary"
    case allTask = "All Task"
    case completed = "Completed"
    case missed = "Missed"
    
    var icon: String {
        switch self {
        case .primary: return "person.fill"
        case .allTask: return "doc.text.fill"
        case .completed: return "checklist"
        case .missed: return "exclamationmark.triangle.fill"
        }
    }
    
    var activeColor: Color {
        switch self {
        case .primary: return Color.blue
        case .allTask: return Color(white: 0.2)
        case .completed: return Color.green.opacity(0.8)
        case .missed: return Color(red: 0.85, green: 0.3, blue: 0.4)
        }
    }
}

// MARK: - 2. HomeView
struct HomeView: View {
    // Akses Database SwiftData
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskModel.dueDate) private var allTasks: [TaskModel]
    @Query private var profiles: [UserModel]
    
    @State private var selectedFilter: FilterTab = .allTask
    @State private var showCreateTask = false
    
    let appBackground = Color("AppBackground")

    // Helper: Angka badge missed tasks
    var missedTaskCount: Int {
        allTasks.filter { $0.status == "missed" }.count
    }
    
    // Mengambil profil pertama (satu-satunya user)
    var currentUser: UserModel? {
        profiles.first
    }
    
    // --- 3. LOGIKA FILTER SESUAI PERMINTAAN ---
    var filteredTasks: [TaskModel] {
        switch selectedFilter {
        case .primary:
            // 3 Tugas Pin (yang belum missed/completed) + Tugas Hari Ini
            let pinned = allTasks.filter { $0.isPinned && $0.status == "todo" }.prefix(3)
            let pinnedIds = Set(pinned.map { $0.taskId })
            
            let today = allTasks.filter {
                Calendar.current.isDateInToday($0.dueDate) &&
                $0.status == "todo" &&
                !pinnedIds.contains($0.taskId)
            }
            return Array(pinned) + today
            
        case .allTask:
            // Semua task yang belum lewat deadline dan belum selesai
            return allTasks.filter { $0.status == "todo" }
            
        case .completed:
            // Semua task yang selesai
            return allTasks.filter { $0.status == "completed" }
            
        case .missed:
            // Semua task yang kelewatan deadline
            return allTasks.filter { $0.status == "missed" }
        }
    }
    
    // --- 4. LOGIKA GROUPING BERDASARKAN TANGGAL ---
    var groupedTasks: [(String, [TaskModel])] {
        // Pisahkan tugas Pinned agar tidak ikut di-grouping (khusus tab Primary)
        let tasksToGroup = selectedFilter == .primary ? filteredTasks.filter { !$0.isPinned } : filteredTasks
        
        let grouped = Dictionary(grouping: tasksToGroup) { task -> String in
            let f = DateFormatter()
            f.dateFormat = "dd-MM-yyyy"
            return f.string(from: task.dueDate)
        }
        
        // Urutkan dari tanggal terlama ke terbaru
        let sortedKeys = grouped.keys.sorted {
            let f = DateFormatter()
            f.dateFormat = "dd-MM-yyyy"
            let d1 = f.date(from: $0) ?? Date.distantPast
            let d2 = f.date(from: $1) ?? Date.distantPast
            return d1 < d2
        }
        
        return sortedKeys.map { ($0, grouped[$0]!) }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // --- HEADER & FILTER ---
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Spacer()
                            HStack(spacing: 12) {
                                NavigationLink(destination: StreakView()) {
                                    HStack(spacing: 4) {
                                        Text("\(currentUser?.streakCount ?? 0)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.orange)
                                        
                                        // Versi ikon yang sudah disesuaikan untuk Header
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 16)) // <-- Diperkecil agar seimbang dengan teks
                                            .foregroundColor(.orange)
                                            .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 2)
                                    }
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.1)) // (Opsional) Tambahan background tipis agar terlihat seperti pil/tombol
                                    .clipShape(Capsule())
                                }
                                
                                NavigationLink(destination: NotificationView()) {
                                    Image(systemName: "bell")
                                        .font(.system(size: 16, weight: .semibold)) // Ukuran icon disamakan
                                        .foregroundColor(.primary)
                                        .frame(width: 36, height: 36) // Ukuran tombol (lingkaran) pasti sama
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                
                                NavigationLink(destination: ProfileView()) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16, weight: .semibold)) // Ukuran icon disamakan
                                        .foregroundColor(.black)
                                        .frame(width: 36, height: 36) // Ukuran tombol (lingkaran) pasti sama
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        
                        Text("All Tasks").font(.system(size: 34, weight: .bold))
                        
                        HStack(spacing: 12) {
                            ForEach(FilterTab.allCases, id: \.self) { tab in
                                FilterPill(tab: tab, isSelected: selectedFilter == tab, badgeCount: tab == .missed ? missedTaskCount : 0) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        selectedFilter = tab
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .background(appBackground)
                    
                    // --- LIST TUGAS SCROLLABLE DENGAN NATIVE LIST ---
                    List {
                        if filteredTasks.isEmpty {
                            Text("Tidak ada tugas.")
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        } else {
                            // 1. Tampilkan Pinned Tasks Khusus di Tab Primary
                            if selectedFilter == .primary {
                                let pinnedTasks = filteredTasks.filter { $0.isPinned }
                                if !pinnedTasks.isEmpty {
                                    Text("Pinned")
                                        .font(.system(size: 18, weight: .bold))
                                        .padding(.top, 0) // <-- 2. Kurangi padding top jadi 0
                                        .padding(.bottom, 4)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                    
                                    ForEach(pinnedTasks) { task in
                                        SwipeableTaskRow(task: task) { completeTask(task: task) }
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20)) // Kurangi jarak antar kartu
                                    }
                                }
                            }
                            
                            // 2. Tampilkan Grouping Berdasarkan Tanggal
                            ForEach(groupedTasks, id: \.0) { dateGroup in
                                Text(formatDateHeader(dateGroup.0))
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.top, selectedFilter == .primary && dateGroup.0 == groupedTasks.first?.0 ? 10 : 0) // Beri sedikit jarak jika di bawah Pinned
                                    .padding(.bottom, 4)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                
                                ForEach(dateGroup.1) { task in
                                    SwipeableTaskRow(task: task) { completeTask(task: task) }
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20)) // Kurangi jarak antar kartu
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.top, -8)
                    .padding(.bottom, 100)
                }
                
                // --- FLOATING ACTION BUTTON ---
                Button(action: { showCreateTask = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium)).foregroundColor(.white)
                        .frame(width: 60, height: 60).background(Color.blue)
                        .clipShape(Circle()).shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(20)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreateTask) {
                TaskSheetView()
            }
            .onAppear {
                // Jalankan pengecekan deadline setiap kali halaman dibuka
                checkAndUpdateMissedTasks()
            }
        }
    }
    
    // --- 5. LOGIKA PENGECEKAN DEADLINE OTOMATIS ---
    private func checkAndUpdateMissedTasks() {
        let now = Date()
        var hasUpdates = false
        
        for task in allTasks {
            // Jika status masih "todo" dan waktu sekarang sudah melewati dueDate
            if task.status == "todo" && now > task.dueDate {
                task.status = "missed"
                hasUpdates = true
            }
        }
        
        // Simpan hanya jika ada perubahan agar hemat memori
        if hasUpdates {
            try? modelContext.save()
            print("Pengecekan selesai: Beberapa tugas telah diupdate menjadi missed.")
        }
    }
    
    private func completeTask(task: TaskModel) {
        withAnimation(.spring()) {
            task.status = "completed"
            try? modelContext.save()
        }
    }
    
    // Ubah string tanggal menjadi "Today", "Yesterday", "Mon, 06 April 2026"
    private func formatDateHeader(_ dateString: String) -> String {
        let f1 = DateFormatter()
        f1.dateFormat = "dd-MM-yyyy"
        guard let d = f1.date(from: dateString) else { return dateString }
        
        let f2 = DateFormatter()
        f2.dateFormat = "E, dd MMMM yyyy"
        f2.locale = Locale(identifier: "en_US")
        
        if Calendar.current.isDateInToday(d) {
            return "Today, " + f2.string(from: d)
        } else if Calendar.current.isDateInYesterday(d) {
            return "Yesterday, " + f2.string(from: d)
        } else if Calendar.current.isDateInTomorrow(d) {
            return "Tomorrow, " + f2.string(from: d)
        }
        return f2.string(from: d)
    }
}

// MARK: - FilterPill
struct FilterPill: View {
    var tab: FilterTab
    var isSelected: Bool
    var badgeCount: Int = 0
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon).font(.system(size: 16, weight: .semibold))
                if isSelected {
                    Text(tab.rawValue).font(.system(size: 15, weight: .semibold)).lineLimit(1).fixedSize()
                }
            }
            .frame(maxWidth: isSelected ? .infinity : nil)
            .padding(.horizontal, isSelected ? 12 : 16)
            .padding(.vertical, 12)
            .background(isSelected ? tab.activeColor : Color.black.opacity(0.08))
            .foregroundColor(isSelected ? .white : .gray.opacity(0.8))
            .clipShape(Capsule())
            .overlay(
                ZStack {
                    if badgeCount > 0 {
                        Text("\(badgeCount)").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                            .frame(width: 18, height: 18).background(Color.red).clipShape(Circle()).offset(x: 6, y: -6)
                    }
                }, alignment: .topTrailing
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}
