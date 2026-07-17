package life.getbible.mobile

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val channelName = "life.getbible.mobile/files"
    private val saveRequest = 501
    private val openRequest = 502
    private var pendingResult: MethodChannel.Result? = null
    private var pendingText: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareText" -> {
                        val text = call.argument<String>("text") ?: ""
                        val subject = call.argument<String>("subject") ?: "getBible.Life"
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, text)
                            putExtra(Intent.EXTRA_SUBJECT, subject)
                        }
                        startActivity(Intent.createChooser(intent, subject))
                        result.success(null)
                    }
                    "saveText" -> {
                        if (!claim(result)) return@setMethodCallHandler
                        pendingText = call.argument<String>("text") ?: ""
                        val filename = call.argument<String>("filename") ?: "getBible-Life.txt"
                        val mimeType = call.argument<String>("mimeType") ?: "text/plain"
                        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = mimeType
                            putExtra(Intent.EXTRA_TITLE, filename)
                        }
                        startActivityForResult(intent, saveRequest)
                    }
                    "pickTextFile" -> {
                        if (!claim(result)) return@setMethodCallHandler
                        val mimeTypes = call.argument<List<String>>("mimeTypes")
                            ?.toTypedArray() ?: arrayOf("application/json", "text/plain")
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "*/*"
                            putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)
                        }
                        startActivityForResult(intent, openRequest)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun claim(result: MethodChannel.Result): Boolean {
        if (pendingResult != null) {
            result.error("busy", "Another file operation is already open.", null)
            return false
        }
        pendingResult = result
        return true
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != saveRequest && requestCode != openRequest) return
        val result = pendingResult ?: return
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            pendingResult = null
            pendingText = null
            result.success(if (requestCode == saveRequest) false else null)
            return
        }
        val uri = data.data!!
        pendingResult = null
        if (requestCode == saveRequest) {
            val text = pendingText ?: ""
            pendingText = null
            thread {
                try {
                    contentResolver.openOutputStream(uri, "w")!!.bufferedWriter().use {
                        it.write(text)
                    }
                    runOnUiThread { result.success(true) }
                } catch (error: Exception) {
                    runOnUiThread {
                        result.error("save_failed", "The file could not be saved.", error.message)
                    }
                }
            }
        } else {
            thread {
                try {
                    val text = contentResolver.openInputStream(uri)!!.bufferedReader().use {
                        it.readText()
                    }
                    runOnUiThread { result.success(text) }
                } catch (error: Exception) {
                    runOnUiThread {
                        result.error("open_failed", "The backup could not be read.", error.message)
                    }
                }
            }
        }
    }
}
