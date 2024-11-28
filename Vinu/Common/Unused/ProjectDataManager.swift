//
//  ProjectDataManager.swift
//  Vinu
//
//  Created by 신정욱 on 9/25/24.
//

/* import UIKit
import CoreData

final class ProjectDataManager {
    
    static let shared  = ProjectDataManager()
    private init() {}
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private lazy var context = appDelegate?.persistentContainer.viewContext
    private let entityName = "ProjectCoreData"
    
    func read() -> [ProjectData] {
        // 임시 저장소 접근한다는 뜻
        guard let context = context else { return [] }
        
        // 어떤 친구 기준으로 소팅할건지?
        let order = NSSortDescriptor(key: "date", ascending: false)
        // 엔티티에 접근한다는 신청서
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        // 왠지 모르겠지만 얘는 배열에 담아서 줘야함
        request.sortDescriptors = [order]
        
        do {
            // fetch() 무조건 배열만 리턴함
            guard let fetched = try context.fetch(request) as? [ProjectCoreData] else { return [] }
            
            let projectData = fetched.map {
                // 관계형 데이터 접근, 코어데이터 타입으로 캐스팅
                let videoCoreData = ($0.items.array as? [VideoCoreData]) ?? [VideoCoreData]()
                // 바깥에서 쓸 타입으로 다시 변환
                let videoData = videoCoreData.map {
                    VideoData(id: $0.id, assetID: $0.assetID, duration: $0.duration)
                }
                
                return ProjectData(id: $0.id, title: $0.title, items: videoData, date: $0.date)
            }
            
            return projectData
        } catch {
            print("읽기 실패")
            return []
        }
    }
    
    func create(from: ProjectData) {
        guard let context = context else { return }

        // 받아온 플젝 데이터로 관계형 객체 배열부터 만들고 값 할당
        let videoCoreDataList = from.items.map {
            let videoCoreData = VideoCoreData(context: context)
            videoCoreData.id = $0.id
            videoCoreData.assetID = $0.assetID
            videoCoreData.duration = $0.duration
            return videoCoreData
        }
        
        // 플젝 코어데이터 객체 만들고 값 할당
        let projectCoreData = ProjectCoreData(context: context)
        projectCoreData.id = from.id
        projectCoreData.title = from.title
        // 위에서 만든 관계형 객체 배열 할당
        projectCoreData.addToItems((NSOrderedSet(array: videoCoreDataList)))
        projectCoreData.date = from.date

        appDelegate?.saveContext()
    }
    
    func delete(target: ProjectData) {
        guard let context = context else { return }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        // id가 같은 값이 들어있는 데이터들 가져오기 (같은 같이 있을리가 없으니 사실상 하나만 가져옴, 스트링은 %@, 정수는 %d)
        request.predicate = NSPredicate(format: "id = %@", target.id as CVarArg)
        
        do {
            // 가져온 데이터를 삭제 (무조건 배열로 가져오고, 조건 맞는 건 다 가져옴)
            guard let fetched = try context.fetch(request) as? [ProjectCoreData] else { return }
            fetched.forEach { context.delete($0) }
            
            appDelegate?.saveContext()
        } catch {
            print("삭제 실패")
        }
    }
    
    func deleteAll() {
        guard let context = context else { return }
        
        // 조건 걸어준 것이 없어서 안에 있는 거 다 들고옴
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            // 가져온 데이터 모두 삭제
            guard let fetched = try context.fetch(request) as? [ProjectCoreData] else { return }
            fetched.forEach{ context.delete($0) }
            
            appDelegate?.saveContext()
        } catch {
            print("삭제 실패")
        }
    }
    
    /// 테스트 못해봄, 사용하게 될 경우 테스트 해볼 것
    func update(target: ProjectData, from: [VideoData]) {
        guard let context = context else { return }
        
        // 교체할 비디오 배열 만들기
        let replacementVideoCoreDataList = from.map {
            let videoCoreData = VideoCoreData(context: context)
            videoCoreData.id = $0.id
            videoCoreData.assetID = $0.assetID
            videoCoreData.duration = $0.duration
            return videoCoreData
        }
        
        // 상위 객체 가져오는 요청서 작성
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "id = %@", target.id as CVarArg)
        
        do {
            // 요청서에 따라 상위 객체 가져오기
            guard let fetched = try context.fetch(request) as? [ProjectCoreData] else { return }
            // 관계형 객체 갱신 (갱신인지 그대로 추가하는건지 잘 모르겠음 테스트 필요)
            fetched.forEach { $0.addToItems((NSOrderedSet(array: replacementVideoCoreDataList))) }
            
            appDelegate?.saveContext()
        } catch {
            print("업데이트 실패")
        }
    }
    
    

    
} */
