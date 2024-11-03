//
//  VideoTrackView.swift
//  Vinu
//
//  Created by 신정욱 on 10/19/24.
//

import UIKit
import AVFoundation
import SnapKit
import RxSwift
import RxCocoa

final class VideoTrackView: UIView {
    private let videoTrackVM = VideoTrackVM()
    
    private let bag = DisposeBag()
    private var isSet = false
    // 외부로부터의 데이터 바인딩을 위한 인풋용 서브젝트
    let sourceIn = PublishSubject<[VideoTrackModel]>()
    let timeRanges = PublishSubject<[CMTimeRange]>()
    let scrollProgress = PublishSubject<CGFloat>()
    let scaleFactor = PublishSubject<CGFloat>()
    
    // MARK: - Components
    let pinchGesture = UIPinchGestureRecognizer()
    let panGestureLeft = UIPanGestureRecognizer()
    let panGestureRight = UIPanGestureRecognizer()

    let scrollView = {
        let view = UIScrollView()
        view.backgroundColor = .white
        view.showsHorizontalScrollIndicator = false
        view.bounces = false // 끝에 부딪혔을 때 일어나는 bounces애니메이션을 비활성화
        return view
    }()

    let contentVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = .zero
        return sv
    }()
    
    let trackIndicator = TrackIndicatorView()
    
    let clipHStack = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        return sv
    }()
    
    let leftSpacer = UIView()
    
    let videoClipCV = {
        let cv = VideoClipCollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(VideoClipCell.self, forCellWithReuseIdentifier: VideoClipCell.identifier)
        cv.showsHorizontalScrollIndicator = true // 스크롤 바 숨기기
        cv.isScrollEnabled = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    let rightSpacer = UIView()

    let leftHandle = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        view.backgroundColor = .yellow
        return view
    }()
    
    let rightHandle = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        view.backgroundColor = .yellow
        return view
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.addGestureRecognizer(pinchGesture)
        leftHandle.addGestureRecognizer(panGestureLeft)
        rightHandle.addGestureRecognizer(panGestureRight)
        
        setAutoLayout()
        setBinding()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 최초로 1번만 실행되게끔 조건 걸어주기
        if !isSet {
            isSet.toggle()
            self.layoutIfNeeded()
            setSpacerWidths()
            setVideoClipCVLayout()
            setTrackIndicatorView()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        self.addSubview(scrollView)
        scrollView.addSubview(contentVStack)
        contentVStack.addArrangedSubview(trackIndicator)
        contentVStack.addArrangedSubview(clipHStack)
        clipHStack.addArrangedSubview(leftSpacer)
        clipHStack.addArrangedSubview(videoClipCV)
        clipHStack.addArrangedSubview(rightSpacer)
        scrollView.addSubview(leftHandle)
        scrollView.addSubview(rightHandle)
        
        scrollView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(70)
        }
        contentVStack.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        trackIndicator.snp.makeConstraints { $0.height.equalTo(10) }
        videoClipCV.snp.makeConstraints { $0.height.equalTo(60) }
    }
    
    // 스크롤뷰의 양쪽 스페이서 넓이 설정
    private func setSpacerWidths() {
        let width = window?.windowScene?.screen.bounds.width ?? .zero
        leftSpacer.snp.makeConstraints { $0.width.equalTo(width / 2) }
        rightSpacer.snp.makeConstraints { $0.width.equalTo(width / 2) }
        
    }
    
    // 클립 컬렉션뷰와 플로우 레이아웃 마저 설정
    private func setVideoClipCVLayout() {
        // 어떤 길이의 영상이 들어올지 모르기 때문에 width는 60으로 설정 후 바인딩 과정에서 초기화
        videoClipCV.setSinglelineLayout(spacing: .zero, width: 60, height: 60)
        let width = videoClipCV.collectionViewLayout.collectionViewContentSize.width
        videoClipCV.snp.makeConstraints { $0.width.equalTo(width) }
    }
    
    private func setTrackIndicatorView() {
        let width = window?.windowScene?.screen.bounds.width ?? .zero
        let count = (width / 10).int
        trackIndicator.pointCount.onNext(count)
    }
    
    // MARK: - Binding
    private func setBinding() {
        // 핀치 제스처를 가공해서 뷰모델에 전달
        let pinchScale = pinchGesture
            .rx.event
            .map { gesture in
                let scale = gesture.scale
                // 연속적 제스처라서 매 호출마다 1.0으로 스케일 초기화
                gesture.scale = 1.0
                return scale
            }
            .distinctUntilChanged()
            .share(replay: 1)
        
        // contentOffset에 따라 포커스 중인 셀의 인덱스 패스를 가공하여 뷰 모델에 인풋으로 전달
        let focusedIndexPath = scrollView
            .rx.contentOffset
            .map { [weak self] _ -> IndexPath? in
                guard let self else { return nil }
                let centerPoint = CGPoint(x: self.scrollView.bounds.midX, y: self.scrollView.bounds.midY)
                let converted = self.scrollView.convert(centerPoint, to: self.videoClipCV)
                
                return self.videoClipCV.indexPathForItem(at: converted)
            }
            .compactMap { $0 }
            .distinctUntilChanged()
            .share(replay: 1)
        
        // 왼쪽 팬 제스처를 가공해서 뷰모델에 전달
        let leftPanTranslation = panGestureLeft
            .rx.event
            .map { [weak self] gesture -> CGPoint? in
                guard let self else { return nil }
                let translation = gesture.translation(in: self.leftHandle)
                // 연속적 제스처이기 때문에 translation을 매번 0으로 초기화 시켜줘야 의도한 동작이 나옴
                gesture.setTranslation(.zero, in: self.leftHandle)
                return translation
            }
            .compactMap { $0 }
            .distinctUntilChanged()
            .share(replay: 1)
        
        // 양 쪽 팬 제스처의 상태를 뷰모델에 전달, 초기값이 있어야 포커스 표시 가능
        let panState = Observable.merge(
            panGestureLeft.rx.event.map { $0.state },
            panGestureRight.rx.event.map { $0.state })
            .startWith(.possible)
            .distinctUntilChanged()
            .share(replay: 1)
        
        
        // 오른쪽 팬 제스처를 가공해서 뷰모델에 전달
        let rightPanTranslation = panGestureRight
            .rx.event
            .map { [weak self] gesture -> CGPoint? in
                guard let self else { return nil }
                let translation = gesture.translation(in: self.rightHandle)
                // 연속적 제스처이기 때문에 translation을 매번 0으로 초기화 시켜줘야 의도한 동작이 나옴
                gesture.setTranslation(.zero, in: self.rightHandle)
                return translation
            }
            .compactMap { $0 }
            .distinctUntilChanged()
            .share(replay: 1)
        
        let scrollProgress_ = scrollView
            .rx.contentOffset
            .map { [weak self] offset -> CGFloat? in
                guard let self else { return nil }
                let contentWidth = self.scrollView.contentSize.width
                let horizontalSpacerWidth = window?.windowScene?.screen.bounds.width ?? .zero
                // 스페이서 만큼의 넓이를 제외해야 실질적인 콘텐츠 사이즈를 얻을 수 있음
                let actualWidth = contentWidth - horizontalSpacerWidth
                
                return offset.x / actualWidth
            }
            .compactMap { $0 }
            .debug()
            .share(replay: 1)
        
        let input = VideoTrackVM.Input(
            sourceIn: sourceIn.asObservable(),
            pinchScale: pinchScale,
            focusedIndexPath: focusedIndexPath,
            leftPanTranslation: leftPanTranslation,
            panState: panState,
            rightPanTranslation: rightPanTranslation,
            scrollProgress: scrollProgress_)
        
        // MARK: - Output
        let output = videoTrackVM.transform(input: input)

        // 셀의 넓이 할당 및 업데이트
        output.cellWidths
            .bind(with: self) { owner, newWidth in
                // 컬렉션 뷰 레이아웃만 업데이트
                owner.videoClipCV.itemWidths = newWidth
                owner.videoClipCV.collectionViewLayout.invalidateLayout()
            }
            .disposed(by: bag)
        
        // 컬렉션 뷰 데이터 소스 바인딩
        output.frameImagesArr
            .bind(to: videoClipCV.rx.items(cellIdentifier: VideoClipCell.identifier, cellType: VideoClipCell.self)) { index, item, cell in
                // 셀 내부 서브젝트에 직접 바인딩
                cell.frameImagesIn.accept(item)
            }
            .disposed(by: bag)
        
        // 핀치나 팬 제스처가 있을 때만 컬렉션 뷰 넓이 업데이트
        output.needUpdateClipCVWidth
            .bind(with: self) { owner, _ in
                // 컬렉션 뷰 자체의 레이아웃 업데이트
                let width = owner.videoClipCV.collectionViewLayout.collectionViewContentSize.width
                owner.videoClipCV.snp.updateConstraints { $0.width.equalTo(width) }
            }
            .disposed(by: bag)
        
        // 좌측 핸들을 잡고 넓이를 줄일 때는 스크롤 뷰의 콘텐츠 오프셋도 같이 움직여야 함
        output.leftPanOffsetShift
            .bind(with: self) { owner, shift in
                // 스크롤 뷰 콘텐츠 오프셋 조정
                let newOffsetX = owner.scrollView.contentOffset.x - shift
                let newOffsetY = owner.scrollView.contentOffset.y
                owner.scrollView.contentOffset = CGPoint(x: newOffsetX, y: newOffsetY)
            }
            .disposed(by: bag)
        
        // 좌측 핸들을 잡고 넓이를 줄일 때는 셀 내부의 컬렉션 뷰의 콘텐츠 오프셋도 같이 움직여야 함
        output.leftPanInnerOffset
            .bind(with: self) { owner, offsetInfo in
                let offsetX = offsetInfo.0
                let path = offsetInfo.1
                
                // 셀 내부의 컬렉션 뷰의 콘텐츠 오프셋 조정 (오프셋 자체를 전달)
                if let cell = owner.videoClipCV.cellForItem(at: path) as? VideoClipCell {
                    let newOffsetX = offsetX
                    let newOffsetY = cell.frameCV.contentOffset.y
                    cell.frameCV.contentOffset = CGPoint(x: newOffsetX, y: newOffsetY)
                }
            }
            .disposed(by: bag)
        
        // 스크롤 뷰의 콘텐츠 오프셋을 기반으로 포커스 되고 있는 셀을 특정 후, 포커스 뷰를 그리기
        output.drawFocusView
            .bind(with: self) { owner, path in
                guard let attributes = owner.videoClipCV.layoutAttributesForItem(at: path) else { return }
                // 왼쪽 스페이서 넓이만큼 오프셋 필요함
                let spacerWidth = owner.leftSpacer.frame.width
                
                // attributes의 프레임 정보를 바탕으로 포커스 뷰 그려주기 (오토레이아웃 필요 없음)
                let leftOrigin = CGPoint(x: attributes.frame.minX + spacerWidth + 10, y: attributes.frame.minY + 20)
                let rightOrigin = CGPoint(x: attributes.frame.maxX + spacerWidth - 18 - 4, y: attributes.frame.minY + 20)
                
                let leftSize = CGSize(width: 8, height: attributes.frame.height - 20)
                let rightSize = CGSize(width: 8, height: attributes.frame.height - 20)
                
                owner.leftHandle.frame = CGRect(origin: leftOrigin, size: leftSize)
                owner.rightHandle.frame = CGRect(origin: rightOrigin, size: rightSize)
            }
            .disposed(by: bag)
        
        // 트랙 뷰 조작에 의해 변경된 시간 범위를 외부에 전달
        output.timeRanges
            .bind(to: timeRanges)
            .disposed(by: bag)
        
        // 스크롤 진행률을 외부에 전달, 총 재생시간에 대해 seek 작업은 상위 뷰에서 처리
        output.scrollProgress
            .bind(to: scrollProgress)
            .disposed(by: bag)
        
        // 확대 배율을 외부에 전달
        output.scaleFactor
            .bind(to: scaleFactor)
            .disposed(by: bag)
    }
}

#Preview {
    VideoTrackView()
}
