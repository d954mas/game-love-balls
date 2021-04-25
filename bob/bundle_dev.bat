if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ../

java -jar bob/bob.jar --settings bob/settings/dev_game.project_settings --archive --with-symbols --variant debug --platform=x86_64-win32 --bo bob/releases/dev/win clean resolve build bundle 

java -jar bob/bob.jar --settings bob/settings/dev_game.project_settings --archive --with-symbols --variant debug --platform=js-web --bo bob/releases/dev/web build bundle 

java -jar bob/bob.jar --settings bob/settings/dev_game.project_settings --archive --with-symbols --variant debug --platform=armv7-android --bo bob/releases/dev/playmarket --settings bob/settings/play_market_game.project_settings resolve build bundle --strip-executable --keystore bob/keystore/debug.jks --keystore-pass bob/keystore/debug_password.txt --keystore-alias game