//
//  EditorVC.swift
//  Vinu
//
//  Created by 신정욱 on 9/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import AVFoundation

final class EditorVC: UIViewController {
    var editorVM: EditorVM!
    private let bag = DisposeBag()
    private var isLazyLayoutSet = false
    
    // MARK: - Components
    let previewPlayerView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var player = PreviewPlayer()
    
    var playerLayer: AVPlayerLayer?
    
    let trackPinchGesture = UIPinchGestureRecognizer()

    let trackScroll = {
        let view = VideoTrackScrollView()
        view.backgroundColor = .chuLightGray
        view.showsHorizontalScrollIndicator = false
        view.bounces = false // 끝에 부딪혔을 때 일어나는 bounces애니메이션을 비활성화
        return view
    }()
    
    
    let trackContentView = UIView()
    
    let trackContentSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = .zero
        return sv
    }()
    
    let videoClipCV = {
        let cv = VideoClipCollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(VideoClipCell.self, forCellWithReuseIdentifier: VideoClipCell.identifier)
        cv.showsHorizontalScrollIndicator = true // 스크롤 바 숨기기
        cv.isScrollEnabled = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    let focus = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    let button = {
        let button = UIButton(configuration: .plain())
        button.setTitle("재생", for: .normal)
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuLightGray
        trackScroll.addGestureRecognizer(trackPinchGesture) // 핀치 제스처 등록

        setAutoLayout()
        setBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isLazyLayoutSet else { return }
        isLazyLayoutSet = true

        // 서브뷰의 레이아웃이 완전히 결정되지 않는 경우에 대비해 레이아웃 업데이트
        view.layoutIfNeeded()
        setVideoTrackInset()
        setVideoClipCVLayout()
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(previewPlayerView)
        view.addSubview(trackScroll)
        trackScroll.addSubview(trackContentView)
        trackContentView.addSubview(trackContentSV)
        trackContentSV.addArrangedSubview(videoClipCV)
        view.addSubview(button)
        view.addSubview(focus)
        
        previewPlayerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(400)
        }
        trackScroll.snp.makeConstraints {
            $0.top.equalTo(previewPlayerView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(60)
        }
        trackContentView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(trackScroll.snp.horizontalEdges)
            $0.height.equalTo(trackScroll.snp.height)
        }
        trackContentSV.snp.makeConstraints { $0.edges.equalTo(trackContentView.snp.edges) }
        
        button.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
    }
    
    // 비디오 트랙의 수평 Inset설정
    private func setVideoTrackInset() {
        let width = view.window?.windowScene?.screen.bounds.width ?? .zero
        trackScroll.contentInset = UIEdgeInsets(horizontal: width / 2)
    }
    
    // 클립 컬렉션뷰와 플로우 레이아웃 마저 설정
    private func setVideoClipCVLayout() {
        // 어떤 길이의 영상이 들어올지 모르기 때문에 width는 60으로 설정 후 바인딩 과정에서 초기화
        videoClipCV.setSinglelineLayout(spacing: .zero, width: 60, height: 60)
        let width = videoClipCV.collectionViewLayout.collectionViewContentSize.width
        videoClipCV.snp.makeConstraints { $0.width.equalTo(width) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        let input = EditorVM.Input(
            playerItemStatus: player.rx.playerItemStatus,
            playerTimeControllStatus: player.rx.timeControlStatus,
            playerElapsedTime: player.rx.elapsedTime,
            
            trackPinchGesture: trackPinchGesture.rx.event.asObservable(),
            didChangeContentOffset: trackScroll.rx.didChangeContentOffset)
        
        let output = editorVM.transform(input: input)

        // 플레이어와 아이템 연결 (플레이어에 연결되기 전까지 아이템은 .unkwon 상태)
        output.playerItem
            .bind(to: player.rx.replaceCurrentItem)
            .disposed(by: bag)
        
        // 아이템의 상태가 .readyToPlay가 되면 플레이어 구성
        output.playerItemStatus
            .bind(with: self) { owner, status in
                guard status == .readyToPlay else { return }
                owner.playerLayer = AVPlayerLayer(player: owner.player)
                owner.playerLayer?.videoGravity = .resizeAspect
                owner.playerLayer?.frame = owner.previewPlayerView.bounds
                
                if let playerLayer = owner.playerLayer {
                    owner.previewPlayerView.layer.addSublayer(playerLayer)
                    // 로딩 후 즉시 탐색을 위해 재생 및 정지
                    owner.player.play()
                    owner.player.pause()
                }
            }
            .disposed(by: bag)
        
        // 영상 진행률에 따라서 스크롤 뷰의 오프셋 변경
        output.playerProgress
            .bind(with: self, onNext: { owner, progress in
                let width = owner.trackScroll.contentSize.width
                let inset = owner.trackScroll.contentInset.left
                // 인셋도 계산에 반영
                owner.trackScroll.contentOffset.x = width * progress - inset
            })
            .disposed(by: bag)
        
        // 비디오 클립 셀 바인딩
        output.frameImages
            .bind(to: videoClipCV.rx.items(cellIdentifier: VideoClipCell.identifier, cellType: VideoClipCell.self)) { index, item, cell in
                cell.frameCV.backgroundColor = .chuColorPalette.randomElement()
                cell.configure(VideoClipCellVM(frameImages: item))
            }
            .disposed(by: bag)
        
        // 클립 셀의 초기 넓이 설정
        output.initalWidths
            .bind(to: videoClipCV.rx.itemWidths)
            .disposed(by: bag)
        
        // 핀치 제스처 중 클립 셀의 넓이 변경
        output.changeWidths
            .bind(with: self) { owner, newWidth in
                // 컬렉션 뷰 레이아웃만 업데이트
                owner.videoClipCV.rx.itemWidths.onNext(newWidth)
                owner.videoClipCV.collectionViewLayout.invalidateLayout()
                // 컬렉션 뷰 자체의 레이아웃 업데이트
                let width = owner.videoClipCV.collectionViewLayout.collectionViewContentSize.width
                owner.videoClipCV.snp.updateConstraints { $0.width.equalTo(width) }
            }
            .disposed(by: bag)
        
        // 영상 탐색
        output.seek
            .bind(with: self) { owner, seekSource in
                let centerPoint = CGPoint(x: owner.trackScroll.bounds.midX, y: owner.trackScroll.bounds.midY)
                print("indexPathForItem", owner.videoClipCV.indexPathForItem(at: centerPoint))
                
                let contentSize = owner.trackScroll.contentSize.width
                let contentOffset = seekSource.0.x + owner.trackScroll.contentInset.left
                let duration = seekSource.1.duration.seconds
                
                let seconds = Double(contentOffset / contentSize * duration)
                let targetTime = CMTime(seconds: seconds , preferredTimescale: 30)
                owner.player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
            }
            .disposed(by: bag)

        // MARK: - temp
        button
            .rx.tap
            .bind(with: self) { owner, _ in
                owner.button.isSelected.toggle()
                
                if owner.button.isSelected {
                    owner.player.play()
                } else {
                    owner.player.pause()
                }
            }
            .disposed(by: bag)
        
    }
}

#Preview {
    EditorVC()
}
