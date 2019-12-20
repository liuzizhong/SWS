//
//  SWSRequest.swift
//  Agency
//
//  Created by strangeliu on 15/8/7.
//  Copyright (c) 2015年 115.com. All rights reserved.
//

import Foundation
//import Alamofire

typealias CompletionHandle = (JSON?, _ error: Error?) -> Any?
typealias ResponseBlock = (Any?, _ isCache: Bool, _ error: Error?) -> Void

enum RequestParams {
    
    case string(String)
    case number(NSNumber)
    case data(Data)
}

class ResponseHandler<T> {
    
    var success: ((T) -> Void)?
    var error: ((Error) -> Void)?
    var always: ((T?, Error?) -> Void)?
    
    init() {
        
    }
    
    func on(success: ((T) -> Void)? = nil, error: ((Error) -> Void)? = nil, always: ((T?, Error?) -> Void)? = nil) {
        self.success = success
        self.error = error
        self.always = always
    }
    
}

extension RequestParams: ExpressibleByStringLiteral {
    
    init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
    
    init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .string(value)
    }
    
    init(unicodeScalarLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension RequestParams: ExpressibleByIntegerLiteral {
    
    init(integerLiteral value: IntegerLiteralType) {
        self = .number(NSNumber(integerLiteral: value))
    }
}

extension RequestParams: ExpressibleByBooleanLiteral {
    
    init(booleanLiteral value: BooleanLiteralType) {
        self = .number(NSNumber(booleanLiteral: value))
    }
}

extension RequestParams: ExpressibleByFloatLiteral {
    
    init(floatLiteral value: FloatLiteralType) {
        self = .number(NSNumber(floatLiteral: value))
    }
}

@objc enum RequestType: Int {
    case get = 0
    case post
    case download
    case upload
}

struct RequestOptions: OptionSet {
    var rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let none = RequestOptions(rawValue: 0)
    static let useHttps = RequestOptions(rawValue: 1 << 0)
    static let disableCache = RequestOptions(rawValue: 1 << 1)
    static let ignoreCacheBeforeRequest = RequestOptions(rawValue: 1 << 2)
    static let disableRetry = RequestOptions(rawValue: 1 << 3)
    static let needDecode = RequestOptions(rawValue: 1 << 4)
}

private let kNetworkRequestRetryTimes = 2
private let kRequestErrorDomain = "com.SWS.request"

class SWSRequest: NSObject {

    var apiResource = ""                //api资源，如login
    var isCloudOfficeAPI = false
    var gid: String?                    //企业ID，不传默认为当前企业，不需要时传""
    var useHTTPS: Bool {
        set { if newValue {options.insert(.useHttps)} else {options.remove(.useHttps)} }
        get { return options.contains(.useHttps) }
    }
    var disableCache: Bool {            //是否禁用缓存 false,只对GET请求有效
        set { if newValue {options.insert(.disableCache)} else {options.remove(.disableCache)} }
        get { return options.contains(.disableCache) }
    }
    var ignoreCacheBeforeRequest: Bool { //是否在请求前忽略缓存 false, disableCache为false时有效
        set { if newValue {options.insert(.ignoreCacheBeforeRequest)} else {options.remove(.ignoreCacheBeforeRequest)} }
        get { return options.contains(.ignoreCacheBeforeRequest) }
    }
    var disableRetry: Bool {                //失败后重试
        set { if newValue {options.insert(.disableRetry)} else {options.remove(.disableRetry)} }
        get { return options.contains(.disableRetry) }
    }
    var disableParse = false
    
    var options = RequestOptions.none
    var customContentType: String?
    
    private var originRequest: Request?
    
    fileprivate(set) var isCache = false                 //当前数据是否是缓存
    fileprivate(set) var mParams = NSMutableDictionary()
    fileprivate(set) var customURLString: String?
    
    fileprivate var completionHandle: CompletionHandle?
    fileprivate var responseBlock: ResponseBlock?
    fileprivate var responseDictorary: ((Any?, Error?) -> Void)?
    private var userInfo: Any?
    fileprivate var retryTimes = kNetworkRequestRetryTimes
    fileprivate var type = RequestType.get
    fileprivate var httpMethod = HTTPMethod.get              //POST vs GET
    fileprivate var uniqueID = arc4random()
    fileprivate var params = [String: Any]()  //请求的字段都放入params里
    
    private var multipartFormData = [FormData]()
    
    fileprivate(set) var responseJSONValue: [String: Any]?
    private(set) var responseData: Data?
    private(set) var responseString: String?
    private(set) var responseSwiftyJSON: JSON?
    
    private(set) var error: Error?

    var url: URL? {
        return originRequest?.request?.url ?? URL(string: buildURLString())
    }
    
    private var downloadPath: URL?
    private var uploadFilePath: URL?
    
    var timeOutInSeconds: Int? = 30
    
    private var needRetry: Bool {
        get {
            return (self.type == .get || self.type == .post) && !self.disableRetry && self.retryTimes > 0
        }
    }
    
    var apiURL = SWSRequest.defaultApiURL()
    
    class func prepareRequest() {
        if SWSRequest.cacheDatabase().open() {
            SWSRequest.cacheDatabase().executeUpdate("CREATE TABLE IF NOT EXISTS RequestCache (cacheKey varchar primary key, cacheContent BLOB, cacheTime INTEGER)", withArgumentsIn: [])
            SWSRequest.cacheDatabase().close()
        }
    }
    
    required override init() {
        super.init()
    }
    
    init(resource: String) {
        super.init()
        apiResource = resource
    }
    
    deinit {
        print("request deinit")
    }
    
    subscript(key: String) -> Any? {
        set(value) {
            params[key] = value
        }
        get {
            return params[key]
        }
    }
    
    @discardableResult func options(_ options: RequestOptions) -> Self {
        self.options = options
        return self
    }
    
    @discardableResult func response(_ block: @escaping ResponseBlock) -> Self {
        responseBlock = block
        return self
    }
    
    @discardableResult func responseDictionary(_ block: @escaping (Any?, Error?) -> Void) -> Self {
        responseDictorary = block
        return self
    }
    
    @discardableResult func completion(_ block: @escaping CompletionHandle) -> Self {
        completionHandle = block
        return self
    }
    
    @discardableResult func appendParams(_ dic: [String: Any]) -> Self {
        dic.forEach({params[$0] = $1})
        return self
    }
    
    @discardableResult func otherGroup(_ gid: String) -> Self {
        self.gid = gid
        return self
    }
    
    @discardableResult func useCustomURLString(_ aURLString: String) -> Self {
        customURLString = aURLString
        encryptAPI = false
        return self
    }
    
    private var customResponseHanlde: ((DataResponse<String>) -> Void)?
    private var customStringEncoding: String.Encoding?
    
    @discardableResult func customResponse(encoding: String.Encoding? = nil, calback: @escaping (DataResponse<String>) -> Void) -> Self {
        self.customStringEncoding = encoding
        self.customResponseHanlde = calback
        return self
    }
    
    @discardableResult func send(_ type: RequestType) -> Self {
        self.type = type
        switch type {
        case .get:
            httpMethod = .get
        case .post:
            httpMethod = .post
        case .upload:
            disableRetry = true
            httpMethod = .post
        case .download:
            disableRetry = true
            httpMethod = .get
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.nanoseconds(1)) {  //此时response还未赋值，需要延时
            self.sendAsync()
        }
        return self
    }
    
    @objc(addData:forKey:mimeType:fileName:)
    func add(data: Data, for key: String, mimeType: String, fileName: String) {
        var formData = FormData(data: data, key: key)
        formData.mimeType = mimeType
        formData.fileName = fileName
        multipartFormData.append(formData)
    }
    
    @discardableResult func addJPEGData(_ data: Data, key: String) -> Self {
        var formData = FormData(data: data, key: key)
        formData.fileName = "file.jpeg"
        multipartFormData.append(formData)
        return self
    }
    
    @discardableResult func getAsync(handle: @escaping CompletionHandle) -> Self {
        self.completion(handle).send(.get)
        return self
    }
    
    @discardableResult func postAsync(handle: @escaping CompletionHandle) -> Self {
        self.completion(handle).send(.post)
        return self
    }
    
    @discardableResult func upload(filePath: String) -> Self {
        var formData = FormData(filePath: filePath, key: "file")
        formData.fileName = (filePath as NSString).lastPathComponent
        multipartFormData.append(formData)
        return self
    }

    @discardableResult func downloadFile(to path: URL) -> Self {
        self.encryptAPI = false // TODO: 下载文件不使用加密，流下载文件的解密还没有支持
        self.downloadPath = path
        self.send(.download)
        return self
    }
    
    private func sendAsync() {
        mParams.forEach({
            if let key = $0.key as? String {
                self.params[key] = $0.value
            }
        })
        mParams.removeAllObjects()
        if type == .get && !disableCache && !ignoreCacheBeforeRequest && retryTimes == kNetworkRequestRetryTimes {
            self.requestFromCache()
        } else {
            if netManager?.isReachable == false/*Reachability.forInternetConnection().currentReachabilityStatus() == NetworkStatus.NotReachable*/ {
//                let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("currentReachabilityStatus()==false -----netManager?.isReachable:\(netManager?.isReachable)-网络异常，请重试", comment: "")])
                let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("网络异常，请重试", comment: "")])
                self.isCache = false
                self.callback(nil, error: error)
            } else {
                appendCookies()
                sendRequest()
            }
        }
    }
    
    fileprivate func sendRequest() {
        let aParams = self.params
        var params = aParams//options.contains(.needDecode) ? EncryptKeygen.m115EncryptRequestParams(aParams) : aParams
        let urlString = customURLString ?? self.buildURLString()
        
        /**
         * 处理Debug模式下可扫描登录多端
         * 默认情况，同一帐号，类似端扫描登录会被提出
         * 为了方便，开启115和115组织同步调试模式可多端扫描登录
         * 当被扫描端是iPad，iPhone～模拟器，真机一起处理，都直接使用iPad端模式
         具体条件是使用请求头信息User-Agent："OfficePad" : "OfficePhone"
         具体规则可全局搜索：User-Agent
         */
        let appName = UIDevice.current.userInterfaceIdiom == .pad ? "SWSPad" : "SWSPhone" // 变成 Universal 版后服务器端仍要区分 iPhone 和 iPad
//        var isBug = false
//        #if DEBUG
//            isBug = true
//        #endif
//        if isBug && urlString.contains("passportapi") && (urlString.contains("login/qrcode") || urlString.contains("logout/index")) {
//            appName = "OfficePad"  //模拟器上二维码的登录和退出，服务端通过userAgent来判断是否iPad，否则模拟器与手机登录不可共存
//        }
//        let version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        let userAgent = "\(appName)/\(SWSApiCenter.getSWSVersion())"
        ////"X-Req-Id": "\(uniqueID)" + "-\(kNetworkRequestRetryTimes - retryTimes)",
        var headers = ["User-Agent": userAgent]
        if let user = SW_UserCenter.shared.user {
            headers["Authorization"] = user.token
//            curStaffId
            params["curStaffId"] = user.id
        }
        let encrypt = false//RequestConfigation.encryptAPI && encryptAPI
        var paramaterEncoding = SWSRequestEncoding(encrypt: encrypt, multipartFormData: multipartFormData)
        paramaterEncoding.customContentType = customContentType
        paramaterEncoding.timeOutInSeconds = timeOutInSeconds
        switch type {
        case .download:
            var destinnation: DownloadRequest.DownloadFileDestination? = nil
            if let downloadPath = downloadPath {
                destinnation =  { (temporaryURL, response) in
                    return (downloadPath, [.removePreviousFile, .createIntermediateDirectories])
                }
            }
            download(urlString, parameters: params, headers: headers, to: destinnation).responseData { [weak self] response in
                guard let weakSelf = self else {
                    return
                }
                if let error = response.result.error {
                    weakSelf.onRequestError(error)
                } else {
                    weakSelf.onRequestCompletion(data: nil)
                }
            }
            break
        default:
            originRequest = request(urlString, method: httpMethod, parameters: params, encoding: paramaterEncoding, headers: headers).responseData {[weak self] response in
//                if let request = response.result {
//                    print(response.result)
//                }
                guard let weakSelf = self else {
                    return
                }
                if let error = response.result.error {
                    weakSelf.onRequestError(error)
                } else {
                    weakSelf.onRequestCompletion(data: response.data)
                }
            }.responseString(queue: DispatchQueue.main, encoding: self.customStringEncoding, completionHandler: { (response) in
                self.responseString = response.result.value
                self.customResponseHanlde?(response)
            })
        }
    }
    
    private func retry() {
        retryTimes -= 1
        if let retryReqest = self.copy() as? SWSRequest {
            retryReqest.sendAsync()
        }
    }
    
    fileprivate func callback(_ json: JSON?, error: NSError?) {
        let cacheFlag = isCache
        var json = json
        var error = error
//        if let aJson = json, options.contains(.needDecode) {
//            let jsonValue = EncryptKeygen.m115DecryptRequestParams(aJson["data"].stringValue)
//            json = JSON(jsonValue)
//        }
        responseSwiftyJSON = json
//        if json != nil && isCloudOfficeAPI {
//            self.responseFlag(&json!)
//        }
        if error != nil {
            if !self.errorFlag(&error!) {
                self.deleteCache()
            }
        }
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { () -> Void in
            let userInfo = self.completionHandle?(json, error)
            dispatch_async_main_safe({ () -> Void in
                self.userInfo = userInfo
                self.responseDictorary?(self.responseJSONValue, error)
                self.responseBlock?(userInfo, cacheFlag, error)
            })
        })
    }
    
    override var description: String {
        let originDescription = super.description
        return originDescription//.unescapeUnicode()
    }
    
    var encryptAPI = false
    
    private func onRequestCompletion(data: Data?) {
//        RequestConfigation.defaultConfigation.requestFinish(nil)
        if type == .download {
            callback(nil, error: nil)
            return
        }
        isCache = false
        var json: JSON?
        let data = data
        responseData = data
        if data != nil { // Data是struct，此处不能改成 if let
            if (/*RequestConfigation.encryptAPI && */self.encryptAPI) {
//                data = EncryptKeygen.ec115DecryptResponse(data!)
                responseData = data
            }
            self.responseJSONValue = (data as NSData?)?.jsonValue() as? [String: Any]
            json = JSON(data: data!)
        }
        if customURLString != nil {
            if json == nil {
                if let str = responseString {
                    json = JSON(str)
                }
            }
            callback(json, error: nil)
            return
        }
        if let json = json {
            #if DEBUG || IN_HOUSE
                print("===========================================================\n")
                print("Request:\n")
                let aParams = self.params
                if let request = originRequest {
                    if type == .post {
                        print(request.cURLRepresentation(with: aParams))
                    } else {
                        debugPrint(request)
                    }
                }
                print("-----------------------------------------------------------\n")
                print("Response:\n")
                print(json)
                print("===========================================================\n")
            #endif
            if json != JSON.null, json["code"].intValue == 0 {//TODO: 服务器返回格式改变
                if (type == .get && !disableCache && data != nil) {
                    updateCache(data!)
                }
                callback(json, error: nil)
            } else if json["code"].intValue == 401 {// code == 401 代表服务器校验token失效了，需要重新登录
                SW_UserCenter.logout({
                    SW_UserCenter.shared.showAlert(message: "您的登录已失效，请重新登录！")
                })
            } else {
                let error = NSError(domain: kRequestErrorDomain, code: errorKeys.flatMap{json[$0].int}.first ?? 0, userInfo: [NSLocalizedDescriptionKey: errorMessageKeys.flatMap{json[$0].string}.first ?? ""])
                callback(json, error: error)
            }
        } else {
            let error = NSError(domain: kRequestErrorDomain, code: 900001, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("返回数据错误", comment: "")])
            callback(nil, error: self.type == .download ? nil : error)
            
        }
    }
    
    private func onRequestError(_ error: Error) {
        print(error)
        
//        RequestConfigation.defaultConfigation.requestFinish(error)
        if self.needRetry && error.code != NSURLErrorTimedOut {
            retry()
        } else {
            isCache = false
            callback(nil, error: error as NSError?)
        }
    }
}

extension SWSRequest: NSCopying {  //copy
    
    func copy(with zone: NSZone? = nil) -> Any {
        let aRequest =  SWSRequest()
        aRequest.apiResource = apiResource
        aRequest.apiURL = apiURL
        aRequest.gid = gid
        aRequest.disableCache = disableCache
        aRequest.ignoreCacheBeforeRequest = ignoreCacheBeforeRequest
        aRequest.isCache = isCache
        aRequest.completionHandle = completionHandle
        aRequest.responseBlock = responseBlock
        aRequest.responseDictorary = responseDictorary
        aRequest.customURLString =? customURLString
        aRequest.type = type
        aRequest.disableRetry = disableRetry
        aRequest.retryTimes = retryTimes
        aRequest.httpMethod = httpMethod
        aRequest.params = [String: Any]()
        aRequest.uniqueID = uniqueID
        aRequest.useHTTPS = useHTTPS
        aRequest.options = options
        aRequest.encryptAPI = encryptAPI
        aRequest.mParams =? mParams.mutableCopy() as? NSMutableDictionary
        for (string, object) in params {
            let key = string.copy() as! String
            if let object = object as? String {
                aRequest[key] = object.copy() as! String
            } else {
                aRequest[key] = object
            }
        }
        return aRequest
    }
}

extension SWSRequest {  //cache
    
    func hasCache(_ block: @escaping (Bool) -> Void) {
        SWSRequest.cacheQueue().async { () -> Void in
            autoreleasepool(invoking: { () -> () in
                var hasCache = false
                guard let cacheKey = self.cacheKey() else {
                    block(false)
                    return
                }
                guard SWSRequest.cacheDatabase().open() else {
                    block(false)
                    return
                }
                if let rs = SWSRequest.cacheDatabase().executeQuery("SELECT cacheContent FROM RequestCache WHERE cacheKey=?", withArgumentsIn: [cacheKey]) {
                    while rs.next() {
                        hasCache = true
                    }
                    rs.close()
                }
                SWSRequest.cacheDatabase().close()
                dispatch_async_main_safe({
                    block(hasCache)
                })
            })
        }
    }
    
    private func cacheKey() -> String? {
        var cacheKeyString = String()
//        if let userID = UDNetwork.sharedUserModel().userID {  + userid
//            cacheKeyString += userID
//        }
        let urlString = buildURLString()
        cacheKeyString += urlString
        for (key, value) in params {
            cacheKeyString += String(format: "&%@=%@", key as String, (value as? CustomStringConvertible)?.description ?? "")
        }
        return cacheKeyString.md5() ?? cacheKeyString
    }
    
    fileprivate func updateCache(_ data: Data) {
        SWSRequest.cacheQueue().async { () -> Void in
            autoreleasepool(invoking: { () -> () in
                guard let cacheKey = self.cacheKey() else {
                    return
                }
                guard SWSRequest.cacheDatabase().open() else {
                    return
                }
                SWSRequest.cacheDatabase().executeUpdate("REPLACE INTO RequestCache (cacheKey, cacheContent, cacheTime) values(?,?,?)", withArgumentsIn: [cacheKey, data, Date().timeIntervalSince1970])
                //SWSRequest.cacheDatabase().close()
            })
        }
    }
    
    func deleteCache() {
        SWSRequest.cacheQueue().async { () -> Void in
            autoreleasepool(invoking: { () -> () in
                guard let cacheKey = self.cacheKey() else {
                    return
                }
                guard SWSRequest.cacheDatabase().open() else {
                    return
                }
                SWSRequest.cacheDatabase().executeUpdate("DELETE FROM RequestCache WHERE cacheKey = ?", withArgumentsIn: [cacheKey])
                //SWSRequest.cacheDatabase().close()
            })
        }
    }
    
    fileprivate func requestFromCache() {
        
        SWSRequest.cacheQueue().async { () -> Void in
            autoreleasepool(invoking: { () -> () in
                guard SWSRequest.cacheDatabase().open() else {
                    return
                }
                if let cacheKey = self.cacheKey() {
                    if let rs = SWSRequest.cacheDatabase().executeQuery("SELECT cacheContent FROM RequestCache WHERE cacheKey=?", withArgumentsIn: [cacheKey]) {
                        var responseCache: Data?
                        while rs.next() {
                            responseCache = rs.data(forColumn: "cacheContent")
                        }
                        rs.close()
                        if let strData = responseCache {
                            self.responseJSONValue = (strData as NSData).jsonValue() as? [String: Any]
                            let json = JSON(data: strData)
                            dispatch_async_main_safe({ () -> Void in
                                self.isCache = true
                                self.callback(json, error: nil)
                            })
                        }
                    }
                }
                if self.type == .get && !self.disableCache && !self.ignoreCacheBeforeRequest {
                    dispatch_async_main_safe({ () -> Void in
                        if netManager?.isReachable == false/*Reachability.forInternetConnection().currentReachabilityStatus() == NetworkStatus.NotReachable*/ {
//                            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("currentReachabilityStatus()==false -----netManager?.isReachable:\(netManager?.isReachable)-网络异常，请重试", comment: "")])
                            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("网络异常，请重试", comment: "")])
                            self.isCache = false
                            self.callback(nil, error: error)
                        } else {
                            self.appendCookies()
                            self.sendRequest()
                        }
                    })
                }
                //SWSRequest.cacheDatabase().close()
            })
        }
    }
    
    class func clearCache() {
        SWSRequest.cacheQueue().async { () -> Void in
            if SWSRequest.cacheDatabase().open() {
                SWSRequest.cacheDatabase().executeUpdate("DELETE * FROM RequestCache", withArgumentsIn: [])
                //SWSRequest.cacheDatabase().close()
            }
        }
    }
}

class SWSGenericRequest<ResponseType>: SWSRequest {
    
    var responseHandler = ResponseHandler<ResponseType>()
    
    private var completionHandler: ((JSON?, Error?) -> ResponseType)?
    
    init(resource: String, completionHandler: @escaping ((JSON?, Error?) -> ResponseType)) {
        super.init(resource: resource)
        self.completionHandler = completionHandler
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func completion(_ block: @escaping CompletionHandle) -> Self {
        fatalError("使用支持泛型的completionHandler处理回调")
    }
    
    @discardableResult func completionHandler(_ handler: @escaping ((JSON?, Error?) -> ResponseType)) -> Self {
        self.completionHandler = handler
        return self
    }
    
    override func callback(_ json: JSON?, error: NSError?) {
        var json = json
        var error = error
        super.callback(json, error: error)
        dispatch_async_main_safe {
            var responseObject: ResponseType?
            if let handler = self.completionHandler {
                if json != nil && self.isCloudOfficeAPI {
                    self.responseFlag(&json!)
                }
                if error != nil {
                    if !self.errorFlag(&error!) {
                        self.deleteCache()
                    }
                }
                let tempResponse = handler(json, error)
                self.responseHandler.success?(tempResponse)
                responseObject = tempResponse
            }
            if let error = error {
                self.responseHandler.error?(error)
            }
            self.responseHandler.always?(responseObject, error)
        }
    }
    
}

extension String {
    
    func md5() -> String? {
        guard let str = self.cString(using: String.Encoding.utf8) else {
            return nil
        }
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str, strLen, result)
        let hash = (0 ..< digestLen).map({String(format: "%02x", result[$0])}).joined(separator: "")
        result.deinitialize(count: digestLen)
        result.deallocate()//deallocate(capacity: digestLen)
        return hash
    }
}

extension Request {
    
    func cURLRepresentation(with params: [String: Any]) -> String {
        var components = ["$ curl -i"]
        
        guard let request = self.request,
            let url = request.url,
            let host = url.host
            else {
                return "$ curl command could not be created"
        }
        
        if let httpMethod = request.httpMethod, httpMethod != "GET" {
            components.append("-X \(httpMethod)")
        }
        
        if let credentialStorage = self.session.configuration.urlCredentialStorage {
            let protectionSpace = URLProtectionSpace(
                host: host,
                port: url.port ?? 0,
                protocol: url.scheme,
                realm: host,
                authenticationMethod: NSURLAuthenticationMethodHTTPBasic
            )
            
            if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
                for credential in credentials {
                    components.append("-u \(credential.user!):\(credential.password!)")
                }
            }
//            else {
//                if let credential = delegate.credential {
//                    components.append("-u \(credential.user!):\(credential.password!)")
//                }
//            }
        }
        
        if session.configuration.httpShouldSetCookies {
            if
                let cookieStorage = session.configuration.httpCookieStorage,
                let cookies = cookieStorage.cookies(for: url), !cookies.isEmpty
            {
                let string = cookies.reduce("") { $0 + "\($1.name)=\($1.value);" }
                components.append("-b \"\(string.substring(to: string.index(before: string.endIndex)))\"")
            }
        }
        
        var headers: [AnyHashable: Any] = [:]
        
        if let additionalHeaders = session.configuration.httpAdditionalHeaders {
            for (field, value) in additionalHeaders where field != AnyHashable("Cookie") {
                headers[field] = value
            }
        }
        
        if let headerFields = request.allHTTPHeaderFields {
            for (field, value) in headerFields where field != "Cookie" {
                headers[field] = value
            }
        }
        
        
        for (field, value) in headers {
            if let base = field.base as? String, base != "Content-Length" {
                components.append("-H \"\(field): \(value)\"")
            }
        }
        
        for (key, value) in params {
            components.append("-d \"\(key)=\(((value as? CustomStringConvertible)?.description ?? ""))\"")
        }
        if let httpBodyData = request.httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
            let escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
//            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")
            
            components.append("-d \"\(escapedBody)\"")
        }
        
        components.append("--compressed")
        components.append("\"\(url.absoluteString)\"")
        return components.joined(separator: " \\\n")
    }
    
}
