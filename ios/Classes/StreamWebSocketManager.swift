//
//  StreamWebSocketManager.swift
//  websocket_manager
//
//  Created by Thongvor on 7/6/21.
//

import Starscream

@available(iOS 9.0, *)
class StreamWebSocketManager: NSObject, WebSocketDelegate {
    var ws: WebSocket?
    var updatesEnabled = false

    var failureCallback: ((_ data: String) -> Void)?
    var openCallback: ((_ data: Bool) -> Void)?
    var messageCallback: ((_ data: String) -> Void)?
    var closeCallback: ((_ data: String) -> Void)?

    var enableRetries: Bool = true

    override init() {
        super.init()

        // print(">>> Stream Manager Instantiated")
    }

    required init(coder _: NSCoder) {
        fatalError(">>> init(coder:) has not been implemented")
    }

    func areUpdateEnabled() -> Bool { return updatesEnabled }

    func create(url: String, header: [String: String]?, enableCompression _: Bool?, disableSSL _: Bool?, enableRetries: Bool) {
        let httpsURL = url.replacingOccurrences(of: "wss://", with: "https://")
        var request = URLRequest(url: URL(string: httpsURL)!)
        if header != nil {
            for key in header!.keys {
                request.setValue(header![key], forHTTPHeaderField: key)
            }
        }
        self.enableRetries = enableRetries
        print(request.allHTTPHeaderFields as Any)
        ws = WebSocket(request: request)
        ws?.delegate = self
//        if(enableCompression != nil) {
//            ws?.enableCompression = enableCompression!
//        } else {
//            ws?.enableCompression = true
//        }
//        if(disableSSL != nil) {
//            ws?.disableSSLCertValidation = disableSSL!
//        } else {
//            ws?.disableSSLCertValidation = false
//        }
        onOpen()
        onClose()
    }

    func onOpen() {
        ws?.onConnect = { [weak self] in
            guard let self = self else { return }
            if self.openCallback != nil {
                (self.openCallback!)(true)
            }
        }
    }
    
    func onFailure() {
        ws?.onDisconnect = { [weak self] (error) in
            guard let self = self else { return }
            if self.failureCallback != nil {
                (self.failureCallback!)(error?.localizedDescription ?? "")
            }
        }
    }

    func connect() {
        onText()
        ws?.connect()
    }

    func disconnect() {
        enableRetries = false
        ws?.disconnect()
    }

    func send(string: String) {
        ws?.write(string: string)
    }

    func onText() {
        ws?.onText = { (text: String) in
            if self.messageCallback != nil {
                (self.messageCallback!)(text)
            }
        }
    }

    func onClose() {
        ws?.onDisconnect = { (error: Error?) in
             print("close \(String(describing: error).debugDescription)")
            if self.enableRetries {
                self.connect()
            } else {
                if self.openCallback != nil {
                    (self.openCallback!)(false)
                }
                if self.closeCallback != nil {
                    if error != nil {
                        if error is WSError {
                            // print("Error message: \((error as! WSError).message)")
                        }
                        (self.closeCallback!)("false")
                        print("close callback calling false")
                    } else {
                        (self.closeCallback!)("true")
                        print("close callback calling true")
                    }
                } else {
                    print("close callback is nil")
                }
            }
        }
    }

    func isConnected() -> Bool {
        if ws == nil {
            return false
        } else {
            return ws!.isConnected
        }
    }

    func echoTest() {
        var messageNum = 0
        ws = WebSocket(url: URL(string: "wss://echo.websocket.org")!)
        ws?.delegate = self
        let send: () -> Void = {
            messageNum += 1
            let msg = "\(messageNum): \(NSDate().description)"
            // print("send: \(msg)")
            self.ws?.write(string: msg)
        }
        ws?.onConnect = {
            // print("opened")
            send()
        }
        ws?.onDisconnect = { (_: Error?) in
            // print("close")
        }
        ws?.onText = { (_: String) in
            // print("recv: \(text)")
            if messageNum == 10 {
                self.ws?.disconnect()
            } else {
                send()
            }
        }
        ws?.connect()
    }

    func websocketDidConnect(socket _: WebSocketClient) {
        //
    }

    func websocketDidDisconnect(socket _: WebSocketClient, error _: Error?) {
        //
    }

    func websocketDidReceiveMessage(socket _: WebSocketClient, text _: String) {
        //
    }

    func websocketDidReceiveData(socket _: WebSocketClient, data _: Data) {
        //
    }
}

