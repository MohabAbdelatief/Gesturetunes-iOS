import AVFoundation
import CoreML
import Vision

// MARK: - CameraModel Class

class CameraModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var musicPlayer: MusicPlayerController?
    
    // MARK: - Properties
    
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var videoDevice: AVCaptureDevice?
    private var handPoseClassifier: HandGestureClassifier? // CoreML Hand Pose Classifier
    
    private var lastDetectedGesture: String = ""
    private var gestureStartTime: Date?
    private let gestureConfirmationDuration: TimeInterval = 2.0 // Seconds required for confirmation
    
    @Published var detectedGesture: String = "No Gesture" // Detected gesture for UI updates
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        setupCamera()
        setupModel()
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        // Configure the video input
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            videoDevice = device
        } else {
            fatalError("No front camera available.")
        }
        
        // Add video input to the capture session
        guard let videoDevice = videoDevice,
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            fatalError("Cannot add video input.")
        }
        captureSession.addInput(videoInput)
        
        // Configure the video output
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.processing"))
            captureSession.addOutput(videoOutput)
        } else {
            fatalError("Cannot add video output.")
        }
        
        captureSession.commitConfiguration()
    }
    
    // MARK: - Session Management
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.stopRunning()
        }
    }
    
    // MARK: - ML Model Setup
    private func setupModel() {
        do {
            // Load the CoreML model
            let handPoseModel = try HandGestureClassifier(configuration: .init())
            self.handPoseClassifier = handPoseModel
        } catch {
            fatalError("Failed to load MLHandPoseClassifier model: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Frame Processing
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Detect hand keypoints using Vision
        let request = VNDetectHumanHandPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        
        do {
            try handler.perform([request])
            
            // Extract hand pose observation
            guard let observations = request.results, let handPose = observations.first else { return }
            
            // Convert keypoints to MLMultiArray for CoreML
            guard let multiArray = try? handPose.keypointsMultiArray() else {
                print("Failed to convert hand keypoints to MLMultiArray.")
                return
            }
            
            
            // Perform prediction using the CoreML model
            guard let handPoseClassifier = handPoseClassifier else { return }
            let prediction = try handPoseClassifier.prediction(poses: multiArray)
            let confidence = prediction.labelProbabilities[prediction.label]!
            // Update the detected gesture
            if confidence > 0.9 {
                DispatchQueue.main.async {
                    self.detectedGesture = prediction.label
                    self.handleGestureWithDelay(prediction.label)
                    print("Detected Gesture: \(prediction.label)")
                    print("\(confidence)")
                }
            }
            else {
                DispatchQueue.main.async {
                    self.detectedGesture = "Unknown"
                }
                print("Detected: \(prediction.label), Low Confidence: \(confidence)")
            }
            
            
        } catch {
            print("Error processing frame: \(error.localizedDescription)")
        }
    }
    
    private func handleGesture(_ gesture: String) {
        guard let musicPlayer = self.musicPlayer else { return }
        
        switch gesture {
        case "Play":
            musicPlayer.isPlaying ? musicPlayer.pause() : musicPlayer.play()
        case "Next":
            musicPlayer.next()
        case "Previous":
            musicPlayer.previous()
        case "Volume Up":
            let newVolume = min(musicPlayer.volume + 0.1, 1.0)
            musicPlayer.setVolume(newVolume)
        case "Volume Down":
            let newVolume = max(musicPlayer.volume - 0.1, 0.0)
            musicPlayer.setVolume(newVolume)
        default:
            print("Unknown gesture: \(gesture)")
        }
    }
    
    private func handleGestureWithDelay(_ gesture: String) {
        if gesture == lastDetectedGesture {
            if let startTime = gestureStartTime, Date().timeIntervalSince(startTime) >= gestureConfirmationDuration {
                handleGesture(gesture)
                gestureStartTime = nil
            }
        } else {
            lastDetectedGesture = gesture
            gestureStartTime = Date()
        }
        
        detectedGesture = gesture
    }
}
