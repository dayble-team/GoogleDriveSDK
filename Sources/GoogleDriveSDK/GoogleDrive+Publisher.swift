//
//  GoogleDrive+Publisher.swift
//  
//
//  Created by 김태완 on 2021/12/21.
//

import Foundation
import Combine

import GoogleAPIClientForREST_Drive



extension GoogleDrive {
    
    public func fetchQueryPublisher<Result: APIObject>(query: APIQueryProtocol) -> AnyPublisher<Result, Error> {
        Future { [weak self] promise in
            self?.execute(query: query) { (result: Result?, error: Error?) in
                guard let result = result else {
                    return promise(.failure(error!))
                }
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
 
    public func downloadPublisher(fileID: String) -> AnyPublisher<APIDataObject, Error> {
        Future { [weak self] promise in
            self?.download(fileID: fileID) { result, error in
                guard let result = result else {
                    return promise(.failure(error!))
                }
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func uploadPublisher(folderID: String? = nil, data: Data, name: String, mimeType: MimeType) -> AnyPublisher<Bool, Error> {
        Future { [weak self] promise in
            self?.upload(folderID: folderID, data: data, name: name, mimeType: mimeType) { result, error in
                guard let error = error else {
                    return promise(.success(result))
                }
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func deletePublisher(fileID: String) -> AnyPublisher<Bool, Error> {
        Future { [weak self] promise in
            self?.deleteFile(fileID: fileID) { result, error in
                guard let error = error else {
                    return promise(.success(result))
                }
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
}
