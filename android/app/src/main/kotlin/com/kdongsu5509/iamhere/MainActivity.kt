package com.kdongsu5509.iamhere

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.provider.ContactsContract
import android.util.Log
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class MainActivity : FlutterActivity() {
    private val CONTACTS_CHANNEL_NAME = "com.iamhere.app/contacts"
    private val METHOD_NAME = "selectContact"
    private val PICK_CONTACT_REQUEST_ID = 1 // 안드로이드에서 사용하는 구분자.

    private var methodResult: MethodChannel.Result? = null // 결과를 저장할 임시 변수

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    /**
     * FCM 포그라운드 알림을 위한 높은 우선순위 알림 채널을 생성합니다.
     * Android 8.0 (API 26) 이상에서 필요합니다.
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "high_importance_channel"
            val channelName = "High Importance Notifications"
            val channelDescription = "앱의 중요한 알림을 표시하는 채널입니다"
            val importance = NotificationManager.IMPORTANCE_HIGH

            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                enableVibration(true)
                enableLights(true)
            }

            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)

            Log.d("MainActivity", "알림 채널 생성 완료: $channelId")
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 연락처 선택 채널 유지
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTACTS_CHANNEL_NAME).setMethodCallHandler {
                call, result ->
            if(call.method == METHOD_NAME) {
                methodResult = result

                val intent = Intent(
                    Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI
                )
                startActivityForResult(intent, PICK_CONTACT_REQUEST_ID)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == PICK_CONTACT_REQUEST_ID) {
            if (resultCode == Activity.RESULT_OK) {
                val contactUri = data?.data
                if (contactUri != null) {
                    val contactMap = getContactFromUri(contactUri)
                    methodResult?.success(contactMap)
                } else {
                    methodResult?.error("CONTACT_PICK_FAILED", "선택된 연락처 URI가 없습니다.", null)
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                methodResult?.success(null)
            }
            methodResult = null
        }
    }

    private fun getContactFromUri(contactUri: android.net.Uri): Map<String, String?> {
        val contactMap = mutableMapOf<String, String?>()
        val contentResolver = contentResolver

        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME_PRIMARY,
            ContactsContract.CommonDataKinds.Phone.NUMBER
        )

        val cursor = contentResolver.query(
            contactUri,
            projection,
            null,
            null,
            null
        )

        cursor?.use {
            if (it.moveToFirst()) {
                val nameIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME_PRIMARY)
                val numberIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)

                if (nameIndex >= 0 && numberIndex >= 0) {
                    val name = it.getString(nameIndex)
                    val number = it.getString(numberIndex)?.replace("[^0-9]".toRegex(), "")

                    contactMap["name"] = name
                    contactMap["number"] = number
                }
            }
        }
        return contactMap
    }
}