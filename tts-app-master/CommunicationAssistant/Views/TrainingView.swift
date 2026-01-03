import SwiftUI
import Vision

@MainActor
class TrainingViewModel: ObservableObject {
    @Published var currentCharacterIndex = 0
    @Published var isCalibrating = false
    @Published var calibrationProgress: Double = 0
    
    let charactersToTrain = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,")
    
    var currentCharacter: String {
        String(charactersToTrain[currentCharacterIndex])
    }
    
    func startCalibration() {
        isCalibrating = true
        calibrationProgress = 0
        // Logic to start capturing landmarks
    }
    
    func nextCharacter() {
        if currentCharacterIndex < charactersToTrain.count - 1 {
            currentCharacterIndex += 1
            isCalibrating = false
            calibrationProgress = 0
        }
    }
}

struct TrainingView: View {
    @StateObject private var viewModel = TrainingViewModel()
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var visionService: VisionService
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Air Typing Calibration")
                .font(.title)
            
            ZStack {
                CameraPreview(session: cameraManager.session)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if viewModel.isCalibrating {
                    ProgressView(value: viewModel.calibrationProgress)
                        .progressViewStyle(.linear)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .padding()
                }
            }
            
            VStack {
                Text("Type this character in the air:")
                    .font(.headline)
                Text(viewModel.currentCharacter)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
            }
            
            Button(action: {
                if viewModel.isCalibrating {
                    viewModel.nextCharacter()
                } else {
                    viewModel.startCalibration()
                }
            }) {
                Text(viewModel.isCalibrating ? "Save & Next" : "Capture Gesture")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onAppear {
            let service = visionService
            cameraManager.start()
            service.start()
            cameraManager.onFrameCaptured = { buffer in
                service.process(sampleBuffer: buffer)
            }
        }
        .onDisappear {
            cameraManager.stop()
            visionService.stop()
        }
    }
}
