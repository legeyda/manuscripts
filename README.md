




deps

	xclip
	yad
	exif

install
	git submodule update --init
	make install prefix=~/.local


To run particular script

	make target/main/script/backspin-run RUN_ARGS=


To unit-test particular script:

	make script-check-test_backspin



gnome-screenshot --clipboard --file $HOME/box/etc/screen-log/$(date +%Y-%m-%d_%H-%m-%S) # экран
gnome-screenshot --clipboard --file $HOME/box/etc/screen-log/$(date +%Y-%m-%d_%H-%m-%S) --area # область
gnome-screenshot --clipboard --file $HOME/box/etc/screen-log/$(date +%Y-%m-%d_%H-%m-%S) --window # окно