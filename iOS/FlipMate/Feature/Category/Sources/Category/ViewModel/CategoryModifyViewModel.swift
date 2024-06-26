//
//  CategoryModifyViewModel.swift
//
//
//  Created by 권승용 on 5/30/24.
//

import Foundation
import Combine

import Domain
import Core
import CategoryService

public struct CategoryModifyViewModelActions {
    public let didFinishCategoryModify: () -> Void
    
    public init(didFinishCategoryModify: @escaping () -> Void) {
        self.didFinishCategoryModify = didFinishCategoryModify
    }
}

public protocol CategoryModifyViewModelInput {
    func createCategory(name: String, colorCode: String?) async throws
    func updateCategory(newName: String, newColorCode: String?) async throws
    func modifyCloseButtonTapped()
    func modifyDoneButtonTapped()
    func performCategoryModification(purpose: CategoryPurpose, name: String, colorCode: String?) async throws
}

public protocol CategoryModifyViewModelOutput {
    var selectedCategoryPublisher: AnyPublisher<StudyCategory?, Never> { get }
}

public typealias CategoryModifyViewModelProtocol = CategoryModifyViewModelInput & CategoryModifyViewModelOutput

public final class CategoryModifyViewModel: CategoryModifyViewModelProtocol {
    
    // MARK: - Subject
    private lazy var selectedCategorySubject = CurrentValueSubject<StudyCategory?, Never>(selectedCategory)
    
    // MARK: - Properites
    private var categoryMananger: CategoryManageable
    private let createCategoryUseCase: CreateCategoryUseCase
    private let updateCategoryUseCase: UpdateCategoryUseCsae
    private let actions: CategoryModifyViewModelActions?
    private let selectedCategory: StudyCategory?
    
    // MARK: - init
    
    public init(createCategoryUseCase: CreateCategoryUseCase,
         updateCategoryUseCase: UpdateCategoryUseCsae,
         categoryManager: CategoryManageable,
         actions: CategoryModifyViewModelActions? = nil,
         selectedCategory: StudyCategory? = nil) {
        self.createCategoryUseCase = createCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.categoryMananger = categoryManager
        self.actions = actions
        self.selectedCategory = selectedCategory
    }
    
    // MARK: - Output
    public var selectedCategoryPublisher: AnyPublisher<StudyCategory?, Never> {
        return selectedCategorySubject.eraseToAnyPublisher()
    }
    
    // MARK: - Input
    public func createCategory(name: String, colorCode: String?) async throws {
        let colorCode = colorCode ?? "000000FF"
        let newCategoryID = try await createCategoryUseCase.createCategory(name: name, colorCode: colorCode)
        let newCategory = StudyCategory(id: newCategoryID, color: colorCode, subject: name, studyTime: 0)
        categoryMananger.append(category: newCategory)
    }
    
    public func updateCategory(newName: String, newColorCode: String?) async throws {
        guard let selectedCategory = selectedCategory else { return FMLogger.general.error("선택된 카테고리 없음")}
        let colorCode = newColorCode ?? "000000FF", studyTime = selectedCategory.studyTime ?? 0
        try await updateCategoryUseCase.updateCategory(of: selectedCategory.id, newName: newName, newColorCode: colorCode)
        let updateCategory = StudyCategory(id: selectedCategory.id, color: colorCode, subject: newName, studyTime: studyTime)
        categoryMananger.change(category: updateCategory)
    }
    
    public func modifyDoneButtonTapped() {
        actions?.didFinishCategoryModify()
    }
    
    public func modifyCloseButtonTapped() {
        actions?.didFinishCategoryModify()
    }
    
    public func performCategoryModification(purpose: CategoryPurpose, name: String, colorCode: String?) async throws {
        do {
            switch purpose {
            case .create:
                try await createCategory(name: name, colorCode: colorCode)
            case .update:
                try await updateCategory(newName: name, newColorCode: colorCode)
            }
            modifyDoneButtonTapped()
        } catch let error as APIError {
            FMLogger.general.error("카테고리 에러 \(error)")
            switch error {
            case .duplicatedCategoryName:
                throw CategoryModificationError.duplicatedName
            default:
                throw CategoryModificationError.unknownError
            }
        }
    }
}

enum CategoryModificationError: Error {
    case duplicatedName
    case unknownError
}
