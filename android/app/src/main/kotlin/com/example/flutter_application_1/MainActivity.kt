package com.example.flutter_application_1

import android.animation.Animator
import android.graphics.Color
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView

import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen

import com.airbnb.lottie.LottieAnimationView
import com.airbnb.lottie.LottieDrawable

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener

import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var splashOverlay: FrameLayout? = null
    private var animationView: LottieAnimationView? = null

    private var splashOverlayReady = false
    private var animationFinished = false
    private var flutterFirstFrameRendered = false
    private var splashDismissed = false

    private var channel: MethodChannel? = null

    private val flutterUiDisplayListener =
        object : FlutterUiDisplayListener {
            override fun onFlutterUiDisplayed() {
                runOnUiThread {
                    flutterFirstFrameRendered = true
                    dismissSplashIfReady()
                }
            }

            override fun onFlutterUiNoLongerDisplayed() = Unit
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()

        splashScreen.setKeepOnScreenCondition {
            !splashOverlayReady
        }

        super.onCreate(savedInstanceState)
        showNativeSplash()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "native_splash").also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    "isDismissed" -> result.success(splashDismissed)
                    else -> result.notImplemented()
                }
            }
        }

        flutterEngine.renderer.addIsDisplayingFlutterUiListener(flutterUiDisplayListener)
    }

    private fun showNativeSplash() {
        val decorView = window.decorView as ViewGroup

        val overlay = FrameLayout(this).apply {
            setBackgroundColor(Color.WHITE)
            elevation = 1000f
        }

        val lottieView = LottieAnimationView(this).apply {
            setAnimation(R.raw.splash_animation)
            repeatCount = 0
            repeatMode = LottieDrawable.RESTART
            speed = 1.5f
            scaleType = ImageView.ScaleType.FIT_CENTER
        }

        overlay.addView(
            lottieView,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            ).apply {
                gravity = Gravity.CENTER
            }
        )

        decorView.addView(
            overlay,
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        )

        splashOverlay = overlay
        animationView = lottieView

        lottieView.addAnimatorListener(
            object : Animator.AnimatorListener {
                override fun onAnimationStart(animation: Animator) = Unit
                override fun onAnimationCancel(animation: Animator) = Unit
                override fun onAnimationRepeat(animation: Animator) = Unit
                override fun onAnimationEnd(animation: Animator) {
                    animationFinished = true
                    dismissSplashIfReady()
                }
            }
        )

        lottieView.addLottieOnCompositionLoadedListener {
            lottieView.progress = 0f

            overlay.viewTreeObserver.addOnPreDrawListener(
                object : android.view.ViewTreeObserver.OnPreDrawListener {
                    override fun onPreDraw(): Boolean {
                        if (!overlay.isAttachedToWindow) {
                            return true
                        }

                        overlay.viewTreeObserver.removeOnPreDrawListener(this)
                        splashOverlayReady = true
                        lottieView.playAnimation()
                        return true
                    }
                }
            )
        }
    }

    private fun dismissSplashIfReady() {
        if (splashDismissed || !animationFinished || !flutterFirstFrameRendered) return
        splashDismissed = true

        (splashOverlay?.parent as? ViewGroup)?.removeView(splashOverlay)
        splashOverlay = null
        animationView = null

        channel?.invokeMethod("dismissed", null)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.renderer.removeIsDisplayingFlutterUiListener(flutterUiDisplayListener)
        channel?.setMethodCallHandler(null)
        channel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}