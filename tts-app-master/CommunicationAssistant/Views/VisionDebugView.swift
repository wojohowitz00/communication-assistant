import SwiftUI
import AVFoundation
import Vision

struct VisionDebugView: View {
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var visionService: VisionService
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            
            HandLandmarkOverlay(observations: visionService.handObservations)
            
            VStack {
                if visionService.isProcessing && visionService.handObservations.isEmpty {
                    Text("No hand detected. Adjust lighting or position.")
                        .font(.caption)
                        .padding(8)
                        .background(.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 40)
                }
                Spacer()
            }
        }
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

#if os(macOS)
typealias PlatformViewRepresentable = NSViewRepresentable
typealias PlatformView = NSView
#else
typealias PlatformViewRepresentable = UIViewRepresentable
typealias PlatformView = UIView
#endif

struct CameraPreview: PlatformViewRepresentable {
    let session: AVCaptureSession
    
    #if os(macOS)
    func makeNSView(context: Context) -> PlatformView {
        let view = PlatformView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        view.layer = layer
        view.wantsLayer = true
        return view
    }
    
    func updateNSView(_ nsView: PlatformView, context: Context) {
        if let layer = nsView.layer as? AVCaptureVideoPreviewLayer {
            layer.session = session
        }
    }
    #else
    func makeUIView(context: Context) -> PlatformView {
        let view = PlatformView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        view.layer = layer
        return view
    }
    
    func updateUIView(_ uiView: PlatformView, context: Context) {
        if let layer = uiView.layer as? AVCaptureVideoPreviewLayer {
            layer.session = session
        }
    }
    #endif
}

struct HandLandmarkOverlay: View {
    let observations: [VNHumanHandPoseObservation]
    
    var body: some View {
        Canvas { context, size in
            for observation in observations {
                guard let points = try? observation.recognizedPoints(.all) else { continue }
                
                for (_, point) in points {
                    guard point.confidence > 0.3 else { continue }
                    
                    // Vision coordinates are normalized (0 to 1) and bottom-up
                    let x = point.location.x * size.width
                    let y = (1 - point.location.y) * size.height
                    
                    let dot = Path(ellipseIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8))
                    context.fill(dot, with: .color(.green))
                }
            }
        }
    }
}
