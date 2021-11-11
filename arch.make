# 
# Copyright (C) 1996-2016	The SIESTA group
#  This file is distributed under the terms of the
#  GNU General Public License: see COPYING in the top directory
#  or http://www.gnu.org/copyleft/gpl.txt.
# See Docs/Contributors.txt for a list of contributors.
#
#-------------------------------------------------------------------
# arch.make file for gfortran compiler.
# To use this arch.make file you should rename it to
#   arch.make
# or make a sym-link.
# For an explanation of the flags see DOCUMENTED-TEMPLATE.make

.SUFFIXES:
.SUFFIXES: .f .F .o .c .a .f90 .F90

SIESTA_ARCH = x86_64_MPI

INSDIR = /opt

CC = mpicc
FPP = $(FC) -E -P -x c
FC = mpif90
FC_SERIAL = gfortran

FFLAGS = -O2 -fPIC -ftree-vectorize -march=native

AR = ar
RANLIB = ranlib

SYS = nag

SP_KIND = 4
DP_KIND = 8
KINDS = $(SP_KIND) $(DP_KIND)

FPPFLAGS = $(DEFS_PREFIX)-DFC_HAVE_ABORT -DUSE_GEMM3M

LDFLAGS =

# MPI setup
MPI_INTERFACE = libmpi_f90.a
MPI_INCLUDE = .

# MPI requirement:
FPPFLAGS += -DMPI

# flook
# INCFLAGS += -I$(INSDIR)/siesta/siesta-4.1-b4/Docs/build/flook/0.7.0/include
# LDFLAGS += -L$(INSDIR)/siesta/siesta-4.1-b4/Docs/build/flook/0.7.0/lib -Wl,-rpath=$(INSDIR)/siesta/siesta-4.1-b4/Docs/build/flook/0.7.0/lib
# LIBS += -lflookall -ldl
# COMP_LIBS += libfdict.a
# FPPFLAGS += -DSIESTA__FLOOK

# netcdf
INCFLAGS += -I$(INSDIR)/Docs/build/netcdf/4.7.4/include
LDFLAGS += -L$(INSDIR)/Docs/build/zlib/1.2.11/lib -Wl,-rpath=$(INSDIR)/Docs/build/zlib/1.2.11/lib
LDFLAGS += -L$(INSDIR)/Docs/build/hdf5/1.12.0/lib -Wl,-rpath=$(INSDIR)/Docs/build/hdf5/1.12.0/lib
LDFLAGS += -L$(INSDIR)/Docs/build/netcdf/4.7.4/lib -Wl,-rpath=$(INSDIR)/Docs/build/netcdf/4.7.4/lib
LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
COMP_LIBS += libncdf.a libfdict.a
FPPFLAGS += -DCDF -DNCDF -DNCDF_4

# openblas
#LDFLAGS += -L$(INSDIR)/openblas/lib -Wl,-rpath=$(INSDIR)/openblas/lib
#LIBS += -lopenblas_nonthreaded

# ScaLAPACK (required only for MPI build)
#LDFLAGS += -L$(INSDIR)/scalapack/lib -Wl,-rpath=$(INSDIR)/scalapack/lib
#LIBS += -lscalapack
LAPACK_LIBS = -L/usr/lib/x86_64-linux-gnu -lblas -llapack
LIBS=$(LAPACK_LIBS)


#
# Make sure you have the appropriate symbols
# (Either explicitly here, or through shell variables, perhaps
#  set by a module system)
ROOT_GLOBAL=/opt/lib/Gfortran
PSML_ROOT=$(ROOT_GLOBAL)
XMLF90_ROOT=$(ROOT_GLOBAL)
GRIDXC_ROOT=$(ROOT_GLOBAL)/mpi
LIBXC_ROOT=$(ROOT_GLOBAL)
#LIBXC_ROOT=/path/to/libxc  
#
# The following include statements will work with recent
# versions of the above libraries (at least those indicated)
#---------------------------------------------
include $(XMLF90_ROOT)/share/org.siesta-project/xmlf90.mk
include $(PSML_ROOT)/share/org.siesta-project/psml.mk
include $(GRIDXC_ROOT)/gridxc.mk
#---------------------------------------------
#
# These are non-optimized libraries. You should
# use optimized versions for production runs.
#
#COMP_LIBS = libsiestaLAPACK.a libsiestaBLAS.a

#FPPFLAGS := $(DEFS_PREFIX)-DFC_HAVE_ABORT $(FPPFLAGS)
#FPPFLAGS := $(DEFS_PREFIX)-D__NO_PROC_POINTERS__ $(FPPFLAGS)

# Dependency rules ---------

FFLAGS_DEBUG = -g -O1   # your appropriate flags here...

# The atom.f code is very vulnerable. Particularly the Intel compiler
# will make an erroneous compilation of atom.f with high optimization
# levels.
atom.o: atom.F
	$(FC) -c $(FFLAGS_DEBUG) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F) $< 
.c.o:
	$(CC) -c $(CFLAGS) $(INCFLAGS) $(CPPFLAGS) $< 
.F.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F)  $< 
.F90.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_free_F90) $< 
.f.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_fixed_f)  $<
.f90.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_free_f90)  $<
