//
//  VideoClipCell.swift
//  Vinu
//
//  Created by 신정욱 on 9/30/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class VideoClipCell: UICollectionViewCell {
    static let identifier = "VideoClipCell"
    
    private var videoClipCellVM: VideoClipCellVM!
    private let bag = DisposeBag()
    var isBind = false

    // MARK: - Components
    let frameCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(FrameCell.self, forCellWithReuseIdentifier: FrameCell.identifier)
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.layer.cornerRadius = 8
        cv.layer.cornerCurve = .continuous
        cv.clipsToBounds = true
        cv.backgroundColor = .chuTint
        return cv
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setAutoLayout()
        setCollectionViewLayout()
        // self.videoClipCellVM = VideoClipCellVM(frameImages: [UIImage(systemName: "macpro.gen3.fill")!.cgImage!])
    }
    
    // override func layoutSubviews() {
    //     super.layoutSubviews()
    //     guard !isBind else { return }
    //     isBind = true
    //     setBinding()
    // }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method Injection
    func configure(_ vm: VideoClipCellVM) {
        self.videoClipCellVM = vm
        setBinding()
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(frameCV)
        frameCV.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(right: 4)) }
    }
    
    private func setCollectionViewLayout() {
        // 모든 수치가 정해져 있기 때문에 layoutSubviews에 배치될 필요는 없음
        frameCV.setSinglelineLayout(spacing: .zero, width: 60, height: 60)
    }
    
    // MARK: - Binding
    private func setBinding() {
        // 현재 셀 프레임의 kvo값을 넓이로 가공해서 뷰모델에 전달
        // let selfWidth = self.rx.observeWeakly(CGRect.self, "frame")
        //     .compactMap { $0 }
        //     .map { $0.width }
        //     .distinctUntilChanged()
        //     .share(replay: 1)
        
        let input = VideoClipCellVM.Input()
        let output = videoClipCellVM.transform(input: input)
        
        output.frameImages
            .bind(to: frameCV.rx.items(cellIdentifier: FrameCell.identifier, cellType: FrameCell.self)) { index, item, cell in
                cell.imageView.image = UIImage(cgImage: item)
            }
            .disposed(by: bag)
    }
    
//    private func getIndexes() -> [Int] {
//        // 클립 셀 넓이 가져오기
//        let width = self.bounds.width
//        // 클립 셀 넓이 기준으로 몇 장의 이미지를 추려내야 하는지
//        let imageCount = ceil(width / 100).int
//        
//        let targetIndexes = Array(0..<imageCount).map {
//            // 0으로 나누면 불상사가 일어나기 때문에 가드 (어차피 처음 이미지는 무조건 0초에 배치됨)
//            guard $0 == 0 else { return 0 }
//            // 이미지가 배치될 곳의 x좌표 뽑아오기
//            let targetLeftOffset = CGFloat($0 * 100)
//            // 이미지가 배치될 곳의 좌표가 클립셀에서 몇 퍼센트 정도 부분인지 가져오기
//            let targetProgress = targetLeftOffset / width * 100
//            // 재생 시간에 진행률을 곱해서 특정 시점을 구하기
//            let targetTimePoint = CGFloat(duration) * targetProgress
//            // 특정 시점에서 가장 가까운 썸네일 이미지 가져오기 (썸네일 이미지는 1초단위로 존재)
//            let targetIndex = targetTimePoint.rounded()
//            // Int타입으로 바꿔서 리턴
//            return targetIndex.int
//        }
//        
//        return targetIndexes
//    }
}

#Preview(traits: .fixedLayout(width: 300, height: 100)) {
    VideoClipCell()
}
