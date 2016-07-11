public class MotionDetector: OperationGroup {
    public var lowPassStrength:Float = 1.0 { didSet {lowPassFilter.strength = lowPassStrength}}
    public var motionDetectedCallback:((position:Position, strength:Float) -> ())?
    
    let lowPassFilter = LowPassFilter()
    let motionComparison = BasicOperation(fragmentShader:MotionComparisonFragmentShader, numberOfInputs:2)
    let averageColorExtractor = AverageColorExtractor()
    
    public override init() {
        super.init()
        
        averageColorExtractor.extractedColorCallback = {[weak self] color in
            self?.motionDetectedCallback?(position:Position(color.redComponent / color.alphaComponent, color.greenComponent / color.alphaComponent), strength:color.alphaComponent)
        }
        
        self.configureGroup{input, output in
            input --> self.motionComparison --> self.averageColorExtractor --> output
            input --> self.lowPassFilter --> self.motionComparison
        }
    }
}
