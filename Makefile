.PHONY: default getv8 getscons buildscons clean cmake

v8ver   := tags/2.3.8
# \ trunk branches/2.5 tags/2.5.9.6
v8svn   := http://v8.googlecode.com/svn/${v8ver}

scons_v    := 2.0.1
scons      := http://downloads.sourceforge.net/project/scons/scons/${scons_v}/scons-${scons_v}.tar.gz
arch       := x64
scons_jobs := 1
mode       := debug

SCONS_ARGS = -j${scons_jobs} arch=${arch} mode=${mode} snapshot=on
# \ profilingsupport=off debuggersupport=off

ifeq (${mode},debug)
libname = libv8_g
else
libname = libv8
endif

default: buildv8

.status:
	touch $@

scons/bin/scons: scons/build/setup.py
	cd scons/build && python setup.py install --prefix=$$PWD/..
	touch $@

scons/build/setup.py: .status
	mkdir -p scons/build && cd scons/build && wget ${scons} && \
	tar xzvf scons*.tar.gz && rm *.tar.gz && mv scons*/* .
	touch $@

v8/ChangeLog: .status
	svn checkout ${v8svn} v8
	touch $@

v8/${libname}.so: v8/ChangeLog scons/bin/scons .status
	cd v8 && CXX=`which g++` ../scons/bin/scons ${SCONS_ARGS} library=shared

v8/${libname}.a: v8/ChangeLog scons/bin/scons .status
	cd v8 && CXX=`which g++` ../scons/bin/scons ${SCONS_ARGS} library=static

getscons: scons/build/setup.py
buildscons: scons/bin/scons
getv8: v8/ChangeLog
buildv8: v8/${libname}.so v8/${libname}.a

clean:
	rm -rf scons v8 obj

cmake:
	mkdir -p obj && cd obj && cmake ..
