import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class APIManager {
    
    static let shared = APIManager()
    static var requestCounter = 0
    
    func simpleRequestWith(method: HTTPMethod, url: String, params: [String: Any]? = nil, headers: [String: String]? = nil, responseHandler: @escaping (DefaultDataResponse) -> Void) {
        let request = Alamofire.request(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: headers)
        let requestNumber = APIManager.requestCounter
        
        log.debug("[\(requestNumber)] REQUEST: \(request)\n PARAMS: \(params)")
        request.response { (response) in
            log.debug("[\(requestNumber)] STATUS CODE: \(self.getStatusCodeFrom(response: response.response))")
            responseHandler(response)
        }
        debugRequestInfo(requestNumber: requestNumber, request: request)
        APIManager.requestCounter += 1
    }
    
    func dataRequestWith<T: Mappable>(responseType: T.Type, method: HTTPMethod, url: String, params: [String: Any]? = nil, headers: [String: String]? = nil, responseHandler: @escaping (DataResponse<T>) -> Void) {
        let request = Alamofire.request(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: headers)
        let requestNumber = APIManager.requestCounter
        log.debug("[\(requestNumber)] REQUEST: \(request)\n PARAMS: \(params)")
        request.responseObject { (response: DataResponse<T>) -> Void in
            log.debug("[\(requestNumber)] STATUS CODE: \(self.getStatusCodeFrom(response: response.response)), RESPONSE TYPED: \(response)")
            responseHandler(response)
        }
        debugRequestInfo(requestNumber: requestNumber, request: request)
        APIManager.requestCounter += 1
    }
    
    func initUserRegistration(responseHandler: @escaping (_ regResponse: RegResponse?) -> Void) {
        let url = "\(APIConstants.BASE_URL)\(APIConstants.INIT_USER)"
        dataRequestWith(responseType: RegResponse.self, method: .post, url: url, responseHandler: { (response) in
            responseHandler(response.result.value)
        })
    }
    
    func validateUser(userId: String, username: String, regSessionId: String, regVerifier: String, responseHandler: @escaping (_ success: Bool) -> Void) {
        let url = "\(APIConstants.BASE_URL)\(APIConstants.VALIDATE)"
        var params = [String: Any]()
        params["UserId"] = userId
        params["UserName"] = username
        params["RegSessionId"] = regSessionId
        params["RegValidationVerifier"] = regVerifier
        
        simpleRequestWith(method: .post, url: url, params: params, headers: nil, responseHandler: { (response) in
            if self.getStatusCodeFrom(response: response.response) == 200 {
               responseHandler(true)
            } else {
               responseHandler(false)
            }
        })
    }
    
    func getUserIdByUsername(username: String, responseHandler: @escaping (_ user: User?) -> Void) {
        let url = "\(APIConstants.BASE_URL)\(APIConstants.USER_LOOKUP)\(username)"
        dataRequestWith(responseType: User.self, method: .get, url: url, responseHandler: { (response) in
            responseHandler(response.result.value)
        })
    }
    
    func approveTresor(tresorId: String, responseHandler: @escaping (_ success: Bool) -> Void) {
        let url = "\(APIConstants.BASE_URL)\(APIConstants.APPROVE_TRESOR)"
        let params: [String: Any] = ["TresorId": tresorId]
        
        simpleRequestWith(method: .post, url: url, params: params, headers: nil) { (response) in
            if self.getStatusCodeFrom(response: response.response) == 200 {
                responseHandler(true)
            } else {
                responseHandler(false)
            }
        }
    }
    
    func approveShare(operationId: String, responseHandler: @escaping (_ success: Bool) -> Void) {
        let url = "\(APIConstants.BASE_URL)\(APIConstants.APPROVE_SHARE)"
        let params: [String: Any] = ["OperationId": operationId]
        
        simpleRequestWith(method: .post, url: url, params: params, headers: nil) { (response) in
            if self.getStatusCodeFrom(response: response.response) == 200 {
                responseHandler(true)
            } else {
                responseHandler(false)
            }
        }
    }
    
    func shareTable(tableId: String, withUser username: String, responseHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        getUserIdByUsername(username: username) { (user) in
            guard let userId = user?.userId else {
                responseHandler(false, "No such user")
                return
            }
            DatabaseManager.shared.getTresorIdByTableId(tableId: tableId, dataHandler: { (snapshot) in
                guard let tresorId = snapshot.value as? String else {
                    responseHandler(false, "Couldn't find tresor for table")
                    return
                }
                ZeroManager.shared.zeroKit?.share(tresorWithId: tresorId, withUser: userId, completion: { (operationId, error) in
                    guard error == nil else {
                        responseHandler(false, error!.localizedDescription)
                        return
                    }
                    self.approveShare(operationId: operationId!, responseHandler: { (success) in
                        responseHandler(success, success ? nil : "Share approval failed")
                    })
                })
            })
        }
    }
    
    func approveInvitationLinkCreation(linkId: String, responseHandler: @escaping (_ success: Bool) -> Void) {
        let url = "\(APIConstants.BASE_URL)\(APIConstants.APPROVE_INVITATION_CREATION)"
        let params: [String: Any] = ["OperationId": linkId]
        
        simpleRequestWith(method: .post, url: url, params: params, headers: nil) { (response) in
            if self.getStatusCodeFrom(response: response.response) == 200 {
                responseHandler(true)
            } else {
                responseHandler(false)
            }
        }
    }
    
    func approveInvitationAcception(operationId: String, responseHandler: @escaping (_ success: Bool) -> Void) {
        let url = "\(APIConstants.BASE_URL)\(APIConstants.APPROVE_INVITATION_ACCEPTION)"
        let params: [String: Any] = ["OperationId": operationId]
        
        simpleRequestWith(method: .post, url: url, params: params, headers: nil) { (response) in
            if self.getStatusCodeFrom(response: response.response) == 200 {
                responseHandler(true)
            } else {
                responseHandler(false)
            }
        }
    }
    
    func createInvitationLink(tableId: String, password: String, message: String, responseHandler: @escaping (_ inviteLink: URL?) -> Void) {
        DatabaseManager.shared.getTresorIdByTableId(tableId: tableId) { (snapshot) in
            guard let tresorId = snapshot.value as? String else {
                responseHandler(nil)
                log.error("TresorId not found for table")
                return
            }
            ZeroManager.shared.zeroKit?.createInvitationLink(with: URL(string: "\(APIConstants.INVITATION_SCHEME)\(APIConstants.INVITATION_HOST)\(APIConstants.INVITATION_PATH)")!, forTresor: tresorId, withMessage: message, password: password, completion: { (inviteLink, error) in
                guard error == nil else {
                    responseHandler(nil)
                    log.error("Invitation link creation failed: \(error?.localizedDescription)")
                    return
                }
                log.debug("Invitation link: \(inviteLink?.url)")
                self.approveInvitationLinkCreation(linkId: inviteLink!.id, responseHandler: { (success) in
                    responseHandler(inviteLink?.url)
                    log.debug("Invitation link: \(inviteLink) approved: \(success)")
                })
            })
        }
    }
    
    func getStatusCodeFrom(response: HTTPURLResponse?) -> Int? {
        return response?.statusCode
    }
    func debugRequestInfo(requestNumber: Int, request: DataRequest) {
        request.responseJSON { (json) in
            log.debug("[\(requestNumber)] RESPONSE JSON: \(json)")
        }
        request.response { (response) in
            log.debug("[\(requestNumber)] RESPONSE FULL: \(response)")
        }
    }
}
