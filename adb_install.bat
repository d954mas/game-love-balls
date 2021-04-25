::adb shell pm uninstall com.d954mas.game.idlemirror.dev
adb install -r "C:\Users\d954m\Desktop\armv7-android\Idle Mirror Dev\Idle Mirror Dev.apk"
adb shell monkey -p com.d954mas.game.idlemirror.dev -c android.intent.category.LAUNCHER 1
pause
