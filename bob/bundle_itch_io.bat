if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ../


java -jar bob/bob.jar --settings bob/settings/release_game.project_settings --settings bob/settings/itch_io_game.project_settings --archive --with-symbols --variant debug --platform=js-web --bo bob/releases/itch_io clean resolve build bundle 
