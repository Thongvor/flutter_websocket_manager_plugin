package br.com.engapp.websocket_manager.models

class MethodName {
    companion object {
        const val PLATFORM_VERSION = "getPlatformVersion"
        const val CREATE = "create"
        const val CONNECT = "connect"
        const val DISCONNECT = "disconnect"
        const val SEND_MESSAGE = "send"
        const val AUTO_RETRY = "autoRetry"
        const val TEST_ECHO = "echoTest"

        const val ON_MESSAGE = "onMessage"
        const val ON_DONE = "onDone"
        const val ON_OPEN = "onOpen"
        const val ON_FAILURE = "onFailure"

        const val LISTEN_MESSAGE = "listen/message"
        const val LISTEN_CLOSE = "listen/close"
        const val LISTEN_OPEN = "listen/open"
        const val LISTEN_FAILURE = "listen/failure"
    }
}