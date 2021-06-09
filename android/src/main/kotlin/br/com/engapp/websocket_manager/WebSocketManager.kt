package br.com.engapp.websocket_manager

import android.os.Handler
import android.os.Looper
import okhttp3.*
import okio.ByteString
import java.util.*


class StreamWebSocketManager: WebSocketListener() {
    private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())
    private var ws: WebSocket? = null
    private val client = OkHttpClient()
    private var url: String? = null
    private var header: Map<String,String>? = null
    var updatesEnabled = false

    var messageCallback: ((String)->Unit)? = null
    var closeCallback: ((String)->Unit)? = null
    var conectedCallback: ((Boolean)->Unit)? = null
    var openCallback: ((String)->Unit)? = null

    var enableRetries: Boolean = true

    override fun onOpen(webSocket: WebSocket, response: Response) {
        if(openCallback != null) {
            uiThreadHandler.post {
                openCallback!!(response.message)
            }
        }
    }
    override fun onMessage(webSocket: WebSocket, text: String) {
        if(messageCallback != null) {
            uiThreadHandler.post {
                messageCallback!!(text)
            }
        }
    }

    override fun onMessage(webSocket: WebSocket, bytes: ByteString) {}

    override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
        t.printStackTrace()
        if (closeCallback != null) {
            uiThreadHandler.post {
                closeCallback!!("true")
            }
        }
    }

    override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
        if(this.enableRetries) {
            this.connect()
        } else {
            uiThreadHandler.post {
                if (closeCallback != null) {
                    closeCallback!!("false")
                }
            }
        }
    }

    fun echoTest() {
        var messageNum = 0
        fun send() {
            messageNum+=1
            val msg = "$messageNum: ${Date()}"
            ws?.send(msg)
        }
        openCallback = fun (text: String): Unit {
            send()
        }
        messageCallback = fun (text: String): Unit {
            if(messageNum == 10) {
                ws?.close(1000,null)
            } else {
                send()
            }
        }
        url = "wss://echo.websocket.org"
        connect()
    }

    fun create(url: String, header: Map<String,String>?) {
        this.url = url
        this.header = header
    }

    fun connect() {
        val reqBuilder: Request.Builder = Request.Builder().url(url!!)
        if(header != null) {
            for(key in header!!.keys) {
                val value: String = (header!![key])!!
                reqBuilder.addHeader(key, value)
            }
        }
        val req: Request = reqBuilder.build()
        ws = client.newWebSocket(req,this)
    }

    fun disconnect() {
        enableRetries = false
        ws?.close(1000,null)
    }

    fun send(msg: String) {
        ws?.send(msg)
    }
}