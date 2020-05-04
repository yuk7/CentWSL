OUT_ZIP=CentOS8.zip
LNCR_EXE=CentOS8.exe

DLR=curl
DLR_FLAGS=-L
BASE_URL=http://cloud.centos.org/centos/8/x86_64/images/CentOS-8-Container-8.1.1911-20200113.3-layer.x86_64.tar.xz
LNCR_ZIP_URL=https://github.com/yuk7/wsldl/releases/download/20040300/icons.zip
LNCR_ZIP_EXE=CentOS.exe

PLANTUML_URL=http://sourceforge.net/projects/plantuml/files/plantuml.jar/download
ACROTEX_URL=http://mirrors.ctan.org/macros/latex/contrib/acrotex.zip
INSTALL_PS_SCRIPT=https://raw.githubusercontent.com/binarylandscapes/AlpineWSL/master/install.ps1
FEATURE_PS_SCRIPT=https://raw.githubusercontent.com/binarylandscapes/AlpineWSL/master/addWSLfeature.ps1

all: $(OUT_ZIP)

zip: $(OUT_ZIP)
$(OUT_ZIP): ziproot
	@echo -e '\e[1;31mBuilding $(OUT_ZIP)\e[m'
	cd ziproot; zip ../$(OUT_ZIP) *

ziproot: Launcher.exe rootfs.tar.gz ps_scripts
	@echo -e '\e[1;31mBuilding ziproot...\e[m'
	mkdir ziproot
	cp Launcher.exe ziproot/${LNCR_EXE}
	cp rootfs.tar.gz ziproot/
	cp install.ps1 ziproot/
	cp addWSLfeature.ps1 ziproot/

ps_scripts:
	$(DLR) $(DLR_FLAGS) $(INSTALL_PS_SCRIPT) -o install.ps1
	$(DLR) $(DLR_FLAGS) $(FEATURE_PS_SCRIPT) -o addWSLfeature.ps1

exe: Launcher.exe
Launcher.exe: icons.zip
	@echo -e '\e[1;31mExtracting Launcher.exe...\e[m'
	unzip icons.zip $(LNCR_ZIP_EXE)
	mv $(LNCR_ZIP_EXE) Launcher.exe

icons.zip:
	@echo -e '\e[1;31mDownloading icons.zip...\e[m'
	$(DLR) $(DLR_FLAGS) $(LNCR_ZIP_URL) -o icons.zip

rootfs.tar.gz: rootfs
	@echo -e '\e[1;31mBuilding rootfs.tar.gz...\e[m'
	cd rootfs; sudo tar -zcpf ../rootfs.tar.gz `sudo ls`
	sudo chown `id -un` rootfs.tar.gz

rootfs: base.tar.xz profile
	@echo -e '\e[1;31mBuilding rootfs...\e[m'
	mkdir rootfs
	sudo tar -xpf base.tar.xz -C rootfs
	sudo cp -f /etc/resolv.conf rootfs/etc/resolv.conf
	sudo cp -f profile rootfs/etc/profile
	sudo chroot rootfs /bin/dnf install -y --nogpgcheck \
		epel-release
	sudo chroot rootfs /bin/dnf install -y --nogpgcheck \
		coreutils-common
	sudo chroot rootfs /bin/dnf install -y --nogpgcheck \
		bash \
		bash-completion \
		sudo \
		passwd \
		make \
		wget \
		curl \
		zip \
		unzip \
		git-lfs \
		subversion \
		genisoimage \
		neofetch \
		openssh \
		nano 
	sudo chroot rootfs /bin/dnf install -y --nogpgcheck \
		gcc \
		ghc-srpm-macros \
		gmp \
		libffi \
		sed \
		zlib-devel
	sudo chroot rootfs /bin/rm /var/lib/rpm/.rpm.lock
	sudo chroot rootfs /bin/dnf install -y --nogpgcheck \
		python36 \
		python3-pip \
		python36-devel \
		python3-numpy \
		graphviz \
		java-11-openjdk-headless \
		ghostscript \
		dejavu-sans-fonts \
		dejavu-sans-mono-fonts \
		dejavu-serif-fonts
	sudo chroot rootfs /bin/dnf --enablerepo=PowerTools install -y --nogpgcheck \
		python3-Cython
	echo "# This file was automatically generated by WSL. To stop automatic generation of this file, remove this line." | sudo tee rootfs/etc/resolv.conf
	sudo chroot rootfs /bin/dnf clean all 
	sudo chroot rootfs /bin/rm -r /var/cache/dnf
	sudo chmod +x rootfs

base.tar.xz:
	@echo -e '\e[1;31mDownloading base.tar.xz...\e[m'
	$(DLR) $(DLR_FLAGS) $(BASE_URL) -o base.tar.xz

clean:
	@echo -e '\e[1;31mCleaning files...\e[m'
	-rm ${OUT_ZIP}
	-rm -r ziproot
	-rm Launcher.exe
	-rm icons.zip
	-rm rootfs.tar.gz
	-sudo rm -r rootfs
	-rm base.tar.xz
	-rm install.ps1
	-rm addWSLfeature.ps1
