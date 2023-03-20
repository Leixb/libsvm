{ lib
, stdenv
, fixDarwinDylibNames
, withOpenMP ? true
}:

stdenv.mkDerivation {
  pname = "libsvm";
  version = "3.31";

  src = ./.;

  patches = lib.optional (!stdenv.isDarwin && withOpenMP) [ ./openmp.patch ];

  buildFlags = [ "lib" "all" ];

  outputs = [ "out" "bin" "dev" ];

  nativeBuildInputs = lib.optionals stdenv.isDarwin [ fixDarwinDylibNames ];

  installPhase =
    let
      libSuff = stdenv.hostPlatform.extensions.sharedLibrary;
      soVersion = "3";
    in
    ''
      runHook preInstall

      install -D libsvm.so.${soVersion} $out/lib/libsvm.${soVersion}${libSuff}
      ln -s $out/lib/libsvm.${soVersion}${libSuff} $out/lib/libsvm${libSuff}

      install -Dt $bin/bin/ svm-scale svm-train svm-predict

      install -Dm644 -t $dev/include svm.h
      mkdir $dev/include/libsvm
      ln -s $dev/include/svm.h $dev/include/libsvm/svm.h

      runHook postInstall
    '';

  meta = with lib; {
    description = "A library for support vector machines";
    homepage = "https://www.csie.ntu.edu.tw/~cjlin/libsvm/";
    license = licenses.bsd3;
    maintainers = [ maintainers.spwhitt ];
    platforms = platforms.unix;
  };
}
