{ stdenv
, lib
, fetchurl
, glib
, pkg-config
, gettext
, libxslt
, python3
, docbook-xsl-nons
, docbook_xml_dtd_42
, libgcrypt
, gobject-introspection
, vala
, gtk-doc
, gnome
, gjs
, libintl
, dbus
, xvfb-run
}:

stdenv.mkDerivation rec {
  pname = "libsecret";
  version = "0.20.4";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "0a4xnfmraxchd9cq5ai66j12jv2vrgjmaaxz25kl031jvda4qnij";
  };

  nativeBuildInputs = [
    pkg-config
    gettext
    libxslt
    docbook-xsl-nons
    docbook_xml_dtd_42
    libintl
    gobject-introspection
    vala
    gtk-doc
    glib
  ];

  buildInputs = [
    libgcrypt
  ];

  propagatedBuildInputs = [
    glib
  ];

  installCheckInputs = [
    python3
    python3.pkgs.dbus-python
    python3.pkgs.pygobject3
    xvfb-run
    dbus
    gjs
  ];

  configureFlags = [
    "--with-libgcrypt-prefix=${libgcrypt.dev}"
  ];

  enableParallelBuilding = true;

  # needs to run after install because typelibs point to absolute paths
  doInstallCheck = false; # Failed to load shared library '/force/shared/libmock_service.so.0' referenced by the typelib

  postPatch = ''
    patchShebangs .
  '';

  installCheckPhase = ''
    export NO_AT_BRIDGE=1
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus.daemon}/share/dbus-1/session.conf \
      make check
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      # Does not seem to use the odd-unstable policy: https://gitlab.gnome.org/GNOME/libsecret/issues/30
      versionPolicy = "none";
    };
  };

  meta = {
    description = "A library for storing and retrieving passwords and other secrets";
    homepage = "https://wiki.gnome.org/Projects/Libsecret";
    license = lib.licenses.lgpl21Plus;
    inherit (glib.meta) platforms maintainers;
  };
}
