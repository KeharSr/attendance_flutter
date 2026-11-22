package com.gbnstore.attendance

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicInteger

class MainActivity : FlutterActivity() {
    private val channelId = "attendance_notifications"
    private val tapAction = "com.kehar.attendance_flutter.NOTIFICATION_TAP"
    private val typeExtra = "attendance_notification_type"
    private val ids = AtomicInteger((System.currentTimeMillis() and 0x3fffffff).toInt())
    private var notificationChannel: MethodChannel? = null
    private var dartReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Attendance notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Attendance updates and reminders"
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        notificationChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.kehar.attendance_flutter/notifications"
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialize" -> {
                        dartReady = true
                        result.success(consumeNotificationType(intent))
                    }
                    "clear" -> {
                        getSystemService(NotificationManager::class.java).cancelAll()
                        result.success(null)
                    }
                    "show" -> {
                        try {
                            result.success(showNotification(
                                call.argument<String>("title") ?: "Attendance update",
                                call.argument<String>("body") ?: "",
                                call.argument<String>("type"),
                                call.argument<String>("messageId")
                            ))
                        } catch (_: SecurityException) {
                            result.success(false)
                        } catch (_: Exception) {
                            result.error("notification-display-failed", "Unable to display notification", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun showNotification(
        title: String,
        body: String,
        type: String?,
        messageId: String?
    ): Boolean {
        val manager = getSystemService(NotificationManager::class.java)
        if (!manager.areNotificationsEnabled()) return false
        createNotificationChannel()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            manager.getNotificationChannel(channelId)?.importance == NotificationManager.IMPORTANCE_NONE) {
            return false
        }
        val id = messageId?.hashCode()?.and(0x7fffffff) ?: ids.incrementAndGet()
        val openIntent = Intent(this, MainActivity::class.java).apply {
            action = tapAction
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(typeExtra, type ?: "")
        }
        val pendingIntent = PendingIntent.getActivity(
            this, id, openIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setPriority(Notification.PRIORITY_HIGH)
                .setDefaults(Notification.DEFAULT_ALL)
        }
        val notification = builder
            .setSmallIcon(R.drawable.ic_stat_notification)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setVisibility(Notification.VISIBILITY_PRIVATE)
            .setCategory(Notification.CATEGORY_STATUS)
            .build()
        manager.notify("attendance_app", id, notification)
        return true
    }

    private fun consumeNotificationType(source: Intent?): String? {
        if (source?.action != tapAction || !source.hasExtra(typeExtra)) return null
        val type = source.getStringExtra(typeExtra)
        source.removeExtra(typeExtra)
        return type
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (dartReady) {
            consumeNotificationType(intent)?.let {
                notificationChannel?.invokeMethod("notificationTapped", it)
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        dartReady = false
        notificationChannel?.setMethodCallHandler(null)
        notificationChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
