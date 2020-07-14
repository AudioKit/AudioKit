// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitUI
import Foundation

let samples = 882

class CompareViewController: UIViewController {
    public var table1 = AKTable(count: samples)
    public var table2 = AKTable(count: samples)

    public var view1: AKTableView?
    public var view2: AKTableView?
    public var slider = UISlider()

    public lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    func setFiles(file1: AVAudioFile, file2: AVAudioFile) {
        for ft in [(file1, table1), (file2, table2)] {
            // if let floats = ft.0.floatChannelData?[0] {
            if let floatChannelData = ft.0.toFloatChannelData() {
                for i in 0 ..< table1.count {
                    ft.1[i] = floatChannelData[0][i]
                }
            }
        }

        view1?.removeFromSuperview()
        view2?.removeFromSuperview()

        let v1 = AKTableView(table1)
        let v2 = AKTableView(table2)
        view.addSubview(v1)
        view.addSubview(v2)

        view1 = v1
        view2 = v2

        view.addSubview(label)
        let ms = Int(Double(table1.count) / file1.fileFormat.sampleRate * 1_000)
        label.text = "<-- \(ms) ms -->"

        view.addSubview(slider)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let b = view.bounds
        let f = b.divided(atDistance: b.height / 2, from: .maxYEdge)
        view1?.frame = f.0
        view2?.frame = f.1
        label.frame = CGRect(origin: .zero, size: CGSize(width: b.width, height: 80))
        slider.frame = b
    }
}
