import SwiftUI
import Shared

struct AnimationEventDialog: View {
    @Binding var isPresented: Bool
    @Binding var event: Shared.AnimationEvent?
    let onSave: (Shared.AnimationEvent) -> Void
    
    @State private var startTime: Double = 0
    @State private var duration: Double = 1
    @State private var type: Shared.AnimationEventType = .spriteChange
    @State private var parameters: [String: Double] = [:]
    
    var body: some View {
        VStack(spacing: 20) {
            Text(event == nil ? "Add Animation Event" : "Edit Animation Event")
                .font(.title)
            
            Form {
                Section("Timing") {
                    HStack {
                        Text("Start Time (beats)")
                        Spacer()
                        TextField("Start", value: $startTime, format: .number)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Duration (beats)")
                        Spacer()
                        TextField("Duration", value: $duration, format: .number)
                            .frame(width: 100)
                    }
                }
                
                Section("Event Type") {
                    Picker("Type", selection: $type) {
                        ForEach(Shared.AnimationEventType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section("Parameters") {
                    ForEach(Array(parameters.keys.sorted()), id: \.self) { key in
                        HStack {
                            Text(key)
                            Spacer()
                            TextField("Value", value: Binding(
                                get: { parameters[key] ?? 0 },
                                set: { parameters[key] = $0 }
                            ), format: .number)
                            .frame(width: 100)
                        }
                    }
                    
                    Button("Add Parameter") {
                        // TODO: Show parameter name input
                    }
                }
            }
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                
                Button("Save") {
                    let newEvent = Shared.AnimationEvent(
                        startTime: startTime,
                        duration: duration,
                        type: type,
                        parameters: parameters
                    )
                    onSave(newEvent)
                    isPresented = false
                }
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            if let event = event {
                startTime = event.startTime
                duration = event.duration
                type = event.type
                parameters = event.parameters
            }
        }
    }
} 