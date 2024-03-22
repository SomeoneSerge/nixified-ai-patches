{
  buildPythonPackage,
  python311Packages,
  fetchFromGitHub,
  pkgs,
  ...
}: let
  nexus-source = fetchFromGitHub {
    owner = "cnr-isti-vclab";
    repo = "nexus";
    rev = "283973ff1751c1941fb86916afe34c50736f275d";
    sha256 = "sha256-eoQHGZoJvcKKprDKGxeqo4PErrx/59wGQa/2H6RH+24=";
  };
in
  buildPythonPackage rec {
    pname = "PyMeshLab";
    version = "2022.2.post4";
    src = fetchFromGitHub {
      owner = "cnr-isti-vclab";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-CtzyKymM/SMoiw413Y+r89R6FEHvEaBS36iDcuRkDCo=";
      fetchSubmodules = true;
    };

    prePatch = ''
      mkdir -p src/meshlab/src/external/downloads/nexus-master/src/
      ln -s ${nexus-source} src/meshlab/src/external/downloads/nexus-master/src/corto
      substituteInPlace "setup.py" --replace "'numpy'" ""
    '';

    propagatedBuildInputs = with python311Packages; [
      setuptools
      numpy
    ];

    configurePhase = ''
      mkdir build && cd build
      cmake ..  "-GNinja" "-DDCMAKE_INSTALL_PREFIX=./pymeshlab"  -DCMAKE_BUILD_TYPE=Release
    '';

    buildPhase = ''
      ninja
      ninja install
      ${python311Packages.pip}/bin/pip wheel .. -w wheels/
    '';

    format = "other";

    pythonImportsCheck = ["pymeshlab"];

    installPhase = ''
      mkdir $out
      ${python311Packages.pip}/bin/pip install ./wheels/*.whl --no-index --no-warn-script-location --prefix="$out" --no-cache $pipInstallFlags
    '';

    nativeBuildInputs = with pkgs; [
      cmake
      ninja
      python311Packages.pythonRelaxDepsHook
      python311Packages.setuptools
      glew
      eigen
      cgal
      boost
      pkg-config
      stdenv.cc.cc.lib
      libGLU
      qt5.wrapQtAppsHook
      gmp
      mpfr
      lib3ds
      qhull
      xercesc
    ];
    buildInputs = with pkgs; [
      libGLU qt5.qtbase gmp mpfr boost glew lib3ds eigen qhull
      xercesc
      muparser
      python311Packages.setuptools
    ];
  }
