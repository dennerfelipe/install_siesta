#Instalador de programas
########################
#Atualizar o sistema

echo "Updating System"
sudo su
apt-get update

########################

echo "Instalar pacotes de compiladores - visualizadores e bibliotecas"
apt install build-essential g++ gfortran libreadline-dev m4 xsltproc -y
apt install openmpi-common openmpi-bin libopenmpi-dev -y
apt-get install vim -y
apt-get install build-essential checkinstall -y
apt-get install openmpi-bin openmpi-doc libopenmpi-dev -y
apt-get install libblacs-mpi-dev -y
apt-get install liblapack-dev -y
apt-get install liblapack3 -y
apt-get install libopenblas-base -y
apt-get install libopenblas-dev -y
apt-get install liblapack-dev libopenblas-dev -y
apt-get install science-physics science-physics-dev science-chemistry science-config science-nanoscale-physics science-nanoscale-physics-dev -y
apt-get install netcdf-bin python3-netcdf4 gfortran -y

# Create required installation folders
echo "Criando pastas em OPT"

SIESTA_DIR=/opt/siesta
OPENBLAS_DIR=/opt/openblas
SCALAPACK_DIR=/opt/scalapack
PSML_DIR=/opt/lib/Gfortran 
NETCDF_DIR=/opt/Docs

# Create folders to OpenBlas, ScalaPack and Siesta.
mkdir -p $SIESTA_DIR $OPENBLAS_DIR $SCALAPACK_DIR $PSML_DIR $NETCDF_DIR

chmod -R 777 $SIESTA_DIR $OPENBLAS_DIR $SCALAPACK_DIR $PSML_DIR $NETCDF_DIR 

# Install single-threaded openblas library from source

echo "INSTALL OPENBLAS"
cd $OPENBLAS_DIR

wget -O OpenBLAS.tar.gz https://ufpr.dl.sourceforge.net/project/openblas/v0.3.7/OpenBLAS%200.3.7%20version.tar.gz

tar xzf OpenBLAS.tar.gz && rm OpenBLAS.tar.gz

cd "$(find . -type d -name xianyi-OpenBLAS*)"

make DYNAMIC_ARCH=0 CC=gcc FC=gfortran HOSTCC=gcc BINARY=64 INTERFACE=64 \
  NO_AFFINITY=1 NO_WARMUP=1 USE_OPENMP=0 USE_THREAD=0 USE_LOCKING=1 LIBNAMESUFFIX=nonthreaded

make PREFIX=$OPENBLAS_DIR LIBNAMESUFFIX=nonthreaded install

cd $OPENBLAS_DIR && rm -rf "$(find $OPENBLAS_DIR -maxdepth 1 -type d -name xianyi-OpenBLAS*)"

################################
# Install ScalaPack from source
################################
echo "INSTALL SCALAPACK"

mpiincdir="/usr/include/mpich"

if [ ! -d "$mpiincdir" ]; then mpiincdir="/usr/lib/x86_64-linux-gnu/openmpi/include" ; fi

cd $SCALAPACK_DIR

wget http://www.netlib.org/scalapack/scalapack_installer.tgz -O ./scalapack_installer.tgz

tar xf ./scalapack_installer.tgz

mkdir -p $SCALAPACK_DIR/scalapack_installer/build/download/

wget https://github.com/Reference-ScaLAPACK/scalapack/archive/v2.1.0.tar.gz -O $SCALAPACK_DIR/scalapack_installer/build/download/scalapack.tgz

cd ./scalapack_installer

echo "b" | ./setup.py --prefix $SCALAPACK_DIR --blaslib=$OPENBLAS_DIR/lib/libopenblas_nonthreaded.a \
  --lapacklib=$OPENBLAS_DIR/lib/libopenblas_nonthreaded.a --mpibindir=/usr/bin --mpiincdir=$mpiincdir 

###############################
# NETCDF INSTALL
###############################
echo "INSTALL NETCDF"

cd $SIESTA_DIR

chmod +x .

wget https://github.com/dennerfelipe/install_siesta/archive/refs/heads/main.zip && cd install_siesta-main && cp * $SIESTA_DIR && cd ../

cp install_netcdf4.bash $NETCDF_DIR && cd $NETCDF_DIR && bash *.bash

echo "INSTALL LIBXC"
# INSTALANDO PSML

# 1 - Configurando LIBXC

cd $PSML_DIR

mkdir INSTALL && cd INSTALL

wget https://github.com/dennerfelipe/libpsml/archive/refs/heads/main.zip

unzip main.zip

cd libpsml-main/

tar -xvf libxc-3.0.1.tar.gz
cd libxc-3.0.1
mkdir Gfortran
cd Gfortran
../configure --prefix=/opt/lib/Gfortran --enable-fortran
make 
make install

# 2 - Configurando XMLF90
cd ../../

tar -xvf xmlf90-1.5.4.tar.gz
cd xmlf90-1.5.4
mkdir Gfortran
cd Gfortran
../configure --prefix=/opt/lib/Gfortran
make
make install

# 3 - Configurando LIBPSML
cd ../../
tar -xvf libpsml-1.1.7.tar.gz
cd libpsml-1.1.7
mkdir Gfortran
cd Gfortran
../configure --prefix=/opt/lib/Gfortran --with-xmlf90=/opt/lib/Gfortran
make 
make install


# 4 - Configurando LIBGRIDXC
cd ../../
tar -xvf libgridxc-0.8.0.tgz
cd libgridxc-0.8.0
mkdir Gfortran
cd  Gfortran
cp ../extra/fortran.mk .
sed -i '5s|.*|LIBXC_ROOT=/opt/lib/Gfortran/|' fortran.mk
sh ../src/config.sh
make clean 
WITH_LIBXC=1 WITH_MPI=1 PREFIX=/opt/lib/Gfortran sh build.sh

############
# SIESTA INSTALL 
###########

cd $SIESTA_DIR

tar xvf *.tgz
cd siesta-psml-R1

# Instalar o Siesta

#Baixar a versão desejada

cd Obj/
sh ../Src/obj_setup.sh && cp /$SIESTA_DIR/arch.make .
cd ../Obj
make

#########################
# Copiando para um local mais adequado

cp $SIESTA_DIR/siesta-psml-R1/Obj/siesta /usr/local/bin
cd 

siesta


#Install Inelastica

#mkdir Inelastica
#cd Inelastica
#wget https://github.com/tfrederiksen/inelastica/archive/refs/heads/master.zip -O Inelastica.zip
