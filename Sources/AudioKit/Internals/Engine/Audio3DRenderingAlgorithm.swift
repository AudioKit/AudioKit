import AVFoundation

enum Audio3DRenderingAlgorithm: Int, Codable, CaseIterable {
	case auto
	case equalPowerPanning
	case HRTF
	case HRTFHQ
	case soundfield
	case sphericalHead
	case stereoPassThrough

	var avRenderingAlgorithm: AVAudio3DMixingRenderingAlgorithm {
		switch self {
			case .auto:
				return .auto
			case .equalPowerPanning:
				return .equalPowerPanning
			case .HRTF:
				return .HRTF
			case .HRTFHQ:
				return .HRTFHQ
			case .sphericalHead:
				return .sphericalHead
			case .soundfield:
				return .soundField
			case .stereoPassThrough:
				return .stereoPassThrough
		}
	}

}
