CC = clang
FRAMEWORKS = -framework Foundation -framework IOKit
SOURCES = HeadphoneAmp.m HeadphoneAmpDaemon.m
TARGET = HeadphoneAmpDaemon

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(CC) $(FRAMEWORKS) $(SOURCES) -o $@

clean:
	rm -f $(TARGET)

install: $(TARGET)
	sudo cp $(TARGET) /usr/local/bin/
	sudo cp com.headphone.amp.plist /Library/LaunchDaemons/
	sudo launchctl load /Library/LaunchDaemons/com.headphone.amp.plist

uninstall:
	sudo launchctl unload /Library/LaunchDaemons/com.headphone.amp.plist
	sudo rm -f /usr/local/bin/$(TARGET)
	sudo rm -f /Library/LaunchDaemons/com.headphone.amp.plist 