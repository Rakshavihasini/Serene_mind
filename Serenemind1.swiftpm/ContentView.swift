import SwiftUI

// MARK: - Anger Log Model
struct AngerLog: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var reason: String
}

// MARK: - ViewModel for Anger Tracking
class AngerLogViewModel: ObservableObject {
    @Published var angerLogs: [AngerLog] = [] {
        didSet { saveLogs() }
    }
    @Published var angerCount: Int = UserDefaults.standard.integer(forKey: "angerCount")

    init() {
        loadLogs()
    }

    func addAngerLog(reason: String) {
        let newLog = AngerLog(date: Date(), reason: reason)
        angerLogs.append(newLog)
        angerCount += 1
        UserDefaults.standard.set(angerCount, forKey: "angerCount")
    }

    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(angerLogs) {
            UserDefaults.standard.set(encoded, forKey: "angerLogs")
        }
    }

    private func loadLogs() {
        if let savedData = UserDefaults.standard.data(forKey: "angerLogs"),
           let decoded = try? JSONDecoder().decode([AngerLog].self, from: savedData) {
            self.angerLogs = decoded
        }
    }
}

// MARK: - HomeView (Anger Tracker)
struct HomeView: View {
    @StateObject private var viewModel = AngerLogViewModel()
    @State private var newReason = ""

    var progress: Double {
        min(Double(viewModel.angerCount) / 50.0, 1.0)
    }

    var body: some View {
        ZStack {
            Color(.systemPurple).opacity(0.2).edgesIgnoringSafeArea(.all) // Light Purple Background
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Anger Tracker")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.purple)

                    // Animated Progress Circle
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.3)
                            .foregroundColor(.purple.opacity(0.5))

                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.8), Color.purple.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut, value: progress)

                        VStack {
                            Text("\(viewModel.angerCount)")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.purple)
                            Text("Total Anger Count")
                                .font(.caption)
                                .foregroundColor(.purple.opacity(0.7))
                        }
                    }
                    .frame(width: 180, height: 180)
                    .shadow(radius: 10)

                    // Anger Log Input
                    TextField("Why did you get angry?", text: $newReason)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)

                    Button(action: {
                        if !newReason.isEmpty {
                            withAnimation(.spring()) {
                                viewModel.addAngerLog(reason: newReason)
                                newReason = ""
                            }
                        }
                    }) {
                        Text("Log Anger")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    // Display Logged Reasons
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Journaled Reasons")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.purple)

                        if viewModel.angerLogs.isEmpty {
                            Text("No reasons logged yet.")
                                .foregroundColor(.purple.opacity(0.7))
                        } else {
                            ForEach(viewModel.angerLogs.reversed()) { log in
                                VStack(alignment: .leading) {
                                    Text(log.reason)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 3)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            }
        }
    }
}

// MARK: - MeditationView (Breathing Animation)
struct MeditationView: View {
    @State private var isBreathing = false

    var body: some View {
        ZStack {
            Color(.systemPurple).opacity(0.2).edgesIgnoringSafeArea(.all) // Light Purple Background
            
            VStack {
                Text("Relax & Breathe")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.purple)
                    .padding()

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 200, height: 200)

                    Circle()
                        .fill(Color.purple.opacity(0.5))
                        .frame(width: isBreathing ? 180 : 120, height: isBreathing ? 180 : 120)
                        .animation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true))
                }
                .onAppear {
                    isBreathing.toggle()
                }

                Text("Breathe in... Breathe out...")
                    .font(.title2)
                    .foregroundColor(.purple.opacity(0.7))
                    .padding()

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Main App Structure
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Tracker", systemImage: "chart.bar.fill")
                }

            MeditationView()
                .tabItem {
                    Label("Meditation", systemImage: "leaf.fill")
                }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
