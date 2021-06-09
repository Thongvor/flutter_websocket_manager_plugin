package br.com.engapp.websocket_manager

import EventStreamHandler
import br.com.engapp.websocket_manager.models.MethodName
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class WebSocketMethodChannelHandler(private val messageStreamHandler: EventStreamHandler,
                                    private val closeStreamHandler: EventStreamHandler,
                                    private val openStreamHandler: EventStreamHandler,
                                    private val failureStreamHandler: EventStreamHandler) : MethodChannel.MethodCallHandler {

    private val websocketManager = StreamWebSocketManager()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            MethodName.PLATFORM_VERSION -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            MethodName.CREATE -> {
                val url: String? = call.argument<String>("url")
                val header:Map<String,String>? = call.argument<Map<String,String>>("header")
                websocketManager.create(url!!, header)
                websocketManager.openCallback = fun (msg: String) {
                    openStreamHandler.send(msg)
                }
                websocketManager.closeCallback = fun (msg: String) {
                    failureStreamHandler.send(msg)
                }
                websocketManager.messageCallback = fun (msg: String) {
                    messageStreamHandler.send(msg)
                }
                websocketManager.closeCallback = fun (msg: String) {
                    closeStreamHandler.send(msg)
                }
                result.success("")
            }
            MethodName.CONNECT -> {
                websocketManager.connect()
                result.success("")
            }
            MethodName.DISCONNECT -> {
                websocketManager.disconnect()
                result.success("")
            }
            MethodName.SEND_MESSAGE -> {
                val message: String = call.arguments()!!
                websocketManager.send(message)
                result.success("")
            }
            MethodName.AUTO_RETRY -> {
                var retry:Boolean? = call.arguments()
                if(retry == null) {
                    retry = true
                }
                websocketManager.enableRetries = retry
                result.success("")
            }
            MethodName.ON_MESSAGE -> {
                websocketManager.messageCallback = fun (msg: String) {
                    messageStreamHandler.send(msg)
                }
                result.success("")
            }
            MethodName.ON_DONE -> {
                websocketManager.closeCallback = fun (msg: String) {
                    closeStreamHandler.send(msg)
                }
                result.success("")
            }
            MethodName.ON_OPEN -> {
                websocketManager.openCallback = fun (msg: String) {
                    openStreamHandler.send(msg)
                }
                result.success("")
            }
            MethodName.ON_FAILURE -> {
                websocketManager.closeCallback = fun (msg: String) {
                    failureStreamHandler.send(msg)
                }
                result.success("")
            }
            MethodName.TEST_ECHO -> {
                websocketManager.echoTest()
                result.success("echo test")
            }
            else -> result.notImplemented()
        }
    }
}