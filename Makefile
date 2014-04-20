CC=clang

all : app

app : Code/*.m
	${CC} -ObjC -fobjc-arc -Os -framework Cocoa Code/*.m -o SloppyProgressive
	mkdir -p SloppyProgressive.app/Contents/MacOS
	mv SloppyProgressive SloppyProgressive.app/Contents/MacOS/
	cp -r Info.plist PkgInfo Resources SloppyProgressive.app/Contents/
	SloppyProgressive.app/Contents/MacOS/SloppyProgressive

analyze :
	${CC} -ObjC -fobjc-arc --analyze Code/*.m 

debug : Code/*.m
	${CC} -ObjC -fobjc-arc -g -framework Cocoa Code/*.m -o SloppyProgressive
	mkdir -p SloppyProgressive.app/Contents/MacOS
	mv SloppyProgressive SloppyProgressive.app/Contents/MacOS/
	cp -r Info.plist PkgInfo Resources SloppyProgressive.app/Contents/
	lldb SloppyProgressive.app/Contents/MacOS/SloppyProgressive

clean :
	rm -rf SloppyProgressive.app SloppyProgressive.dSYM *~ */*~

