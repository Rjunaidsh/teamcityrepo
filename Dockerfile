FROM debian
#RUN apt-get update
#RUN apt-get upgrade
#RUN apt-get install wget -y
#RUN wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/debian/pre-install.sh | sh;
#RUN cd /usr/src/fusionpbx-install.sh/debian && ./install.sh
Run apt update
Run apt install gcc-c++
Run apt install devtoolset-8-gcc devtoolset-8-gcc-c++
Run scl enable devtoolset-8 -- bash

Run apt install cmake
Run apt install make
Run apt install -y git 
Run apt install shellcheck



Run dirBuildSource=/ 
#home/ubuntu/src/tcc

Run printf "%s\n%s\n%s\n%s\n%s\n%s\n" \
"${dirBuildSource}/2021.3.0/" \
"${dirBuildSource}/build-host/" \
"${dirBuildSource}/build-target/" \
"${dirBuildSource}/libraries.compute.tcc-tools/" \
"${dirBuildSource}/libraries.compute.tcc-tools.docs/" \
"${dirBuildSource}/libraries.compute.tcc-tools.infrastructure/"

Run $ chmod -R 777 ${dirBuildSource}/build* ${dirBuildSource}/libraries*
Run $ chmod -R 755 ${dirBuildSource}/2021.3.0

Run dirBuildRoot=/
#home/tcc/build
#dockerImage=hub.docker.com/repository/docker
#echo "Using ${dockerImage} as source of Docker build container."
#dockerCommand="docker run -it -v ${dirBuildSource}:${dirBuildRoot}:z ${dockerImage}"
#echo "${dockerCommand}"
#eval "${dockerCommand}"

# ############################################################################

# Perform a "host build" (cmake + make).
# Note that ${dirBuildRoot}/build is used twice: for host build and again for target build.
# Doing this to minimize path differences between the host and target build results.
Run set -ex   
Run rm -rf ${dirBuildRoot}/build*  # remove folder with contents
Run mkdir ${dirBuildRoot}/build    # make directory with name
Run cd ${dirBuildRoot}/build       # change directory that name
Run cmake -DBUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${dirBuildRoot}/build/host -DHOST_STRUCTURE=ON -DPACKAGE_TYPE=PUBLIC ${dirBuildRoot}/libraries.compute.tcc-tools 

#make VERBOSE=1
#-j $(nproc) 2>&1 | tee ${dirBuildRoot}home/build/build_log.txt

#make VERBOSE=1  # 2>&1 | tee ${dirBuildRoot}/build/build_log.txt
#make doc -j $(nproc)
#make install -j $(nproc)

Run cd ..
Run mv ${dirBuildRoot}/build ${dirBuildRoot}/build-host

# Part two: turn the usr folder into a tar.gz file.

Run rm -rf ${dirBuildRoot}/build/tcc_tools*.tar.gz
Run tar --owner=root --group=root --exclude='usr/tests' -cvzf ${dirBuildRoot}/build/tcc_tools_target_2022.1.0.tar.gz usr

# Part three: add efi module (by way of edk2 project).
Run set -ex
Run mkdir -p /opt
Run cd /opt
Run rm -rf edk2
Run git clone https://github.com/tianocore/edk2.git
Run cd edk2
Run git checkout tags/edk2-stable202105 -B edk2-stable202105
Run git submodule update --init
Run make -C BaseTools

Run rm -rf ${dirBuildRoot}/build/edk2
Run cp -r /opt/edk2 ${dirBuildRoot}/build/
Run cd ${dirBuildRoot}/build
Run make -C edk2/BaseTools
Run cd edk2
Run shellcheck source=/dev/null
Run source edksetup.sh-
Run patch -p1 < ${dirBuildRoot}/libraries.compute.tcc-tools.infrastructure/ci/edk2/tcc_target.patch
Run sed -i "s+path_to_detector.inf+${dirBuildRoot}/libraries.compute.tcc-tools/tools/rt_checker/efi/Detector.inf+g" ShellPkg/ShellPkg.dsc
#build

Run cd ${dirBuildRoot}/build
Run rm -rf usr
Run tar -xzf tcc_tools_target_2022.1.0.tar.gz
Run cp edk2/Build/Shell/RELEASE_GCC5/X64/tcc_rt_checker.efi usr/share/tcc_tools/tools/
Run tar -czvf tcc_tools_target_2022.1.0.tar.gz usr

# End of target build.
# Rename the "build" folder to "build-target"
Run cd ${dirBuildRoot}
Run mv ${dirBuildRoot}/build ${dirBuildRoot}/build-target
ENV PORT=80
Expose 80
