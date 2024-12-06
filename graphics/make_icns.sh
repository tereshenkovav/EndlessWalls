mkdir EndlessWalls.iconset
sips -z 16 16     main_1024x1024.png --out EndlessWalls.iconset/icon_16x16.png
sips -z 32 32     main_1024x1024.png --out EndlessWalls.iconset/icon_16x16@2x.png
sips -z 32 32     main_1024x1024.png --out EndlessWalls.iconset/icon_32x32.png
sips -z 64 64     main_1024x1024.png --out EndlessWalls.iconset/icon_32x32@2x.png
sips -z 128 128   main_1024x1024.png --out EndlessWalls.iconset/icon_128x128.png
sips -z 256 256   main_1024x1024.png --out EndlessWalls.iconset/icon_128x128@2x.png
sips -z 256 256   main_1024x1024.png --out EndlessWalls.iconset/icon_256x256.png
sips -z 512 512   main_1024x1024.png --out EndlessWalls.iconset/icon_256x256@2x.png
sips -z 512 512   main_1024x1024.png --out EndlessWalls.iconset/icon_512x512.png
cp main_1024x1024.png EndlessWalls.iconset/icon_512x512@2x.png
iconutil -c icns EndlessWalls.iconset
rm -R EndlessWalls.iconset
