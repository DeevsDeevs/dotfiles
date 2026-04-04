bin/audio_devices: audio_devices.c | bin
	clang -std=c99 -O3 -framework CoreAudio -framework CoreFoundation $< -o $@

bin:
	mkdir bin
