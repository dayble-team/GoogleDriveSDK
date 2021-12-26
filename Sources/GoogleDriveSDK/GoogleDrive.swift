
import Foundation

import GoogleSignIn
import GoogleAPIClientForREST_Drive
import GTMAppAuth


public final class GoogleDrive {
    public static let shared = GoogleDrive()
    
    var service = GTLRDriveService()
    
    func configuration(with user: GIDGoogleUser?) {
        service.shouldFetchNextPages = true
        service.isRetryEnabled = true
        service.authorizer = user?.authentication.fetcherAuthorizer()
    }
    
    public func fetchQuery<Result: APIObject>(query: APIQueryProtocol, completion: ((Result?, Error?) -> Void)?) -> APIServiceTicket {
        service.executeQuery(query) { callbackTicket, _result, error in
            completion?(_result as? Result, error)
        }
    }

    public func download(fileID: String, completion: ((APIDataObject?, Error?) -> Void)?) {
        let query = GTLRDriveQuery_FilesGet.query(withFileId: fileID)
        execute(query: query, completion: completion)
    }
    
    
    /// 파일 업로드
    /// - Parameters:
    ///   - folderID: null 이면 root drive, appDataFolder 또는 folderID 사용
    ///   - data: 업로드할 데이터
    ///   - name: 업로드할 파일명
    ///   - mimeType: mineType
    ///   - completion: 성공 응답
    public func upload(folderID: String? = "appDataFolder", data: Data, name: String, mimeType: MimeType, completion: ((Bool, Error?) -> Void)?) {
        let file = GTLRDrive_File()
        file.name = name
        if let folderID = folderID {
            file.parents = [folderID]
        }
        let params = GTLRUploadParameters(data: data, mimeType: mimeType.rawValue)
        params.shouldUploadWithSingleRequest = true
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: params)
        query.fields = "id"
        
        service.executeQuery(query, completionHandler: { (ticket, file, error) in
            guard let error = error else {
                completion?(true, nil)
                return
            }
            completion?(false, error)
        })
    }
    
    public func createFolder(spaces: DriveSpaceOptions? = nil,
                             name: String,
                             completion: ((String?, Error?) -> Void)?) {
        fetchFile(spaces: spaces, by: name) { [weak self] file, error in
            if let file = file {
                completion?(file.identifier, nil)
                return
            }
            
            let folder = GTLRDrive_File()
            folder.mimeType = MimeType.googleDriveFolder.rawValue
            folder.name = name
            
            if let spaces = spaces {
                folder.parents = spaces.parents
            }
            let query = GTLRDriveQuery_FilesCreate
                .query(withObject: folder, uploadParameters: nil)
            self?.execute(query: query) { (file: GTLRDrive_File?, error: Error?) in
                guard let error = error else {
                    completion?(file?.identifier, nil)
                    return
                }
                completion?(nil, error)
            }
        }
    }
    
    /// 파일 상세정보
    public func fetchFileDetails(fileID: String, completion: ((APIBatchResult?, Error?) -> Void)?) {
        let revisionQuery = GTLRDriveQuery_RevisionsList.query(withFileId: fileID)
        revisionQuery.completionBlock = { callbackTicket, revisionList, error in
            
        }
        
        let permissionQuery = GTLRDriveQuery_PermissionsList.query(withFileId: fileID)
        permissionQuery.completionBlock = { callbackTicket, permissionList, error in
            
        }
        
        let childQuery = GTLRDriveQuery_FilesList.query()
        childQuery.q = "'\(fileID)' in parents"
        childQuery.completionBlock = { callbackTicket, fileList, error in
            
        }
        
        let parentsQuery = GTLRDriveQuery_FilesGet.query(withFileId: fileID)
        parentsQuery.fields = "parents"
        parentsQuery.completionBlock = { callbackTicket, file, error in
            
        }
        
        // Combine the separate queries into one batch.
        let batchQuery = GTLRBatchQuery()
        batchQuery.addQuery(revisionQuery)
        batchQuery.addQuery(permissionQuery)
        batchQuery.addQuery(childQuery)
        batchQuery.addQuery(parentsQuery)
        execute(query: batchQuery, completion: completion)
    }
    
    
    /// 파일삭제
    /// - Parameter fileID: fileID description
    public func deleteFile(fileID: String, completion: ((Bool, Error?) -> Void)?) {
        let query = GTLRDriveQuery_FilesDelete.query(withFileId: fileID)
        service.executeQuery(query) { callbackTicket, _, error in
            guard let error = error else {
                completion?(true, nil)
                return
            }
            completion?(false, error)
        }
    }
}


// MARK: - Internal
extension GoogleDrive {
    @discardableResult
    func execute<Result: APIObject>(query: APIQueryProtocol, completion: ((Result?, Error?) -> Void)?) -> APIServiceTicket {
        service.executeQuery(query) { callbackTicket, _result, error in
            completion?(_result as? Result, error)
        }
    }
    
}


extension GoogleDrive {
    public func fetchFileList(spaces: DriveSpaceOptions? = nil,
                              by mimeType: MimeType,
                              completion: ((APIDriveFileList?, Error?) -> Void)?) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.spaces = spaces?.querySpaces
        query.q = "mimeType = '\(mimeType.rawValue)'"
        execute(query: query, completion: completion)
    }
    
    public func fetchFileList(spaces: DriveSpaceOptions? = nil,
                              by name: String,
                              completion: ((APIDriveFileList?, Error?) -> Void)?) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.spaces = spaces?.querySpaces
        query.q = "name contains '\(name)'"
        execute(query: query, completion: completion)
    }
    
    public func fetchFileList(spaces: DriveSpaceOptions? = nil,
                              completion: ((APIDriveFileList?, Error?) -> Void)?) {
        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = spaces?.querySpaces
        query.fields = "nextPageToken, files(id, name)"//kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,trashed)"
        execute(query: query, completion: completion)
    }
    
    
    public func fetchFile(spaces: DriveSpaceOptions? = nil,
                              by name: String,
                              completion: ((APIDriveFile?, Error?) -> Void)?) {
        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = spaces?.querySpaces
        query.q = "name contains '\(name)'"
        execute(query: query) { (list: APIDriveFileList?, error: Error?) in
            completion?(list?.files?.first, error)
        }
    }
}
