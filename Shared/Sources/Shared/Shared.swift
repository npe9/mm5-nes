import Foundation

public struct Note: Codable, Identifiable, Equatable {
    public let id: UUID
    public var pitch: Int
    public var startTime: Double
    public var duration: Double
    public var velocity: Double
    public var instrument: Int
    public var effects: [NoteEffect]
    
    public var description: String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let octave = pitch / 12
        let noteName = noteNames[pitch % 12]
        return "\(noteName)\(octave)"
    }
    
    public init(
        pitch: Int,
        startTime: Double,
        duration: Double,
        velocity: Double = 1.0,
        instrument: Int = 0,
        effects: [NoteEffect] = []
    ) {
        self.id = UUID()
        self.pitch = max(0, min(127, pitch))
        self.startTime = max(0, startTime)
        self.duration = max(0, duration)
        self.velocity = max(0, min(127, velocity))
        self.instrument = max(0, instrument)
        self.effects = effects
    }
    
    public static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id &&
        lhs.pitch == rhs.pitch &&
        lhs.startTime == rhs.startTime &&
        lhs.duration == rhs.duration &&
        lhs.velocity == rhs.velocity &&
        lhs.instrument == rhs.instrument &&
        lhs.effects == rhs.effects
    }
}

public struct NoteEffect: Codable, Equatable {
    public var type: EffectType
    public var value: Double
    
    public init(type: EffectType, value: Double) {
        self.type = type
        self.value = type.clampValue(value)
    }
}

public enum EffectType: String, Codable, CaseIterable, Equatable {
    case arpeggio = "Arpeggio"
    case pitchBend = "Pitch Bend"
    case vibrato = "Vibrato"
    case tremolo = "Tremolo"
    case volumeSlide = "Volume Slide"
    case noteSlide = "Note Slide"
    case noteCut = "Note Cut"
    case noteDelay = "Note Delay"
    case dutyCycle = "Duty Cycle"
    
    public func clampValue(_ value: Double) -> Double {
        switch self {
        case .arpeggio:
            return max(0, min(15, value))
        case .pitchBend:
            return max(-12, min(12, value))
        case .vibrato:
            return max(0, min(127, value))
        case .tremolo:
            return max(0, min(127, value))
        case .volumeSlide:
            return max(-127, min(127, value))
        case .noteSlide:
            return max(-12, min(12, value))
        case .noteCut:
            return max(0, min(96, value))
        case .noteDelay:
            return max(0, min(96, value))
        case .dutyCycle:
            return max(0, min(3, value))
        }
    }
}

public struct AnimationEvent: Codable, Identifiable, Equatable {
    public let id: UUID
    public var startTime: Double
    public var duration: Double
    public var type: AnimationEventType
    public var parameters: [String: Double]
    
    public init(
        startTime: Double,
        duration: Double,
        type: AnimationEventType,
        parameters: [String: Double] = [:]
    ) {
        self.id = UUID()
        self.startTime = startTime
        self.duration = duration
        self.type = type
        self.parameters = parameters
    }
    
    public static func == (lhs: AnimationEvent, rhs: AnimationEvent) -> Bool {
        lhs.id == rhs.id &&
        lhs.startTime == rhs.startTime &&
        lhs.duration == rhs.duration &&
        lhs.type == rhs.type &&
        lhs.parameters == rhs.parameters
    }
}

public enum AnimationEventType: String, Codable, CaseIterable, Equatable {
    case spriteChange = "Sprite Change"
    case positionChange = "Position Change"
    case scaleChange = "Scale Change"
    case rotationChange = "Rotation Change"
    case colorChange = "Color Change"
    case visibilityChange = "Visibility Change"
}

public struct AnimationTrack: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var spriteId: UUID
    public var events: [AnimationEvent]
    
    public init(
        name: String,
        spriteId: UUID,
        events: [AnimationEvent] = []
    ) {
        self.id = UUID()
        self.name = name
        self.spriteId = spriteId
        self.events = events
    }
    
    public static func == (lhs: AnimationTrack, rhs: AnimationTrack) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.spriteId == rhs.spriteId &&
        lhs.events == rhs.events
    }
}

public struct Pattern: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var notes: [Note]
    public var tempo: Int
    public var length: Int
    public var nextPattern: UUID?
    public var animationTracks: [AnimationTrack]
    
    public init(
        name: String,
        notes: [Note] = [],
        tempo: Int = 120,
        length: Int = 64,
        nextPattern: UUID? = nil,
        animationTracks: [AnimationTrack] = []
    ) {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.tempo = tempo
        self.length = length
        self.nextPattern = nextPattern
        self.animationTracks = animationTracks
    }
    
    public static func == (lhs: Pattern, rhs: Pattern) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.notes == rhs.notes &&
        lhs.tempo == rhs.tempo &&
        lhs.length == rhs.length &&
        lhs.nextPattern == rhs.nextPattern &&
        lhs.animationTracks == rhs.animationTracks
    }
}

public struct PlaybackState {
    public var isPlaying: Bool = false
    public var tempo: Double = 120.0
    public var volume: Double = 0.5
    public var currentPattern: Pattern?
    public var currentPosition: Double = 0
    public var selectedInstrument: Int = 0
    
    public init() {}
} 