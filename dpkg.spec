# build-buddah substitutes these
Name: dpkg
Version: 0
Release: 0
Source:

License: GPL
Summary: Dpkg modified for /usr/local
Group: Utilities/System
URL: http://packages.qa.debian.org/d/dpkg.html
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires: quilt 
BuildRequires: imake 
BuildRequires: perl 
BuildRequires: automake 
BuildRequires: autoconf

# RPM gets confused - we require these but they are included in the package
Provides: perl(controllib.pl)
Provides: perl(dpkg-gettext.pl)

%description
Dpkg modified for /usr/local.

%prep
%setup

%build
make quilt
pushd dpkg+chaos
   %{configure} $(../scripts/configopts.sh) --sysconfdir=%{_sysconfdir} \
       --mandir=%{_mandir} 
   make
popd

%install
mkdir -p $RPM_BUILD_ROOT
make -C dpkg+chaos install DESTDIR=$RPM_BUILD_ROOT
cp etc/dpkg.cfg $RPM_BUILD_ROOT/%{_sysconfdir}/dpkg
cp scripts/dpkg-initialize.sh $RPM_BUILD_ROOT/%{_sbindir}/dpkg-initialize
# remove extraneous build products - bin
for file in dselect scanpackages scansources source shlibdeps gencontrol buildpackage distaddfile parsechangelog checkbuilddeps genchanges name; do
    rm -f $RPM_BUILD_ROOT%{_bindir}/dpkg-${file}
    rm -f $RPM_BUILD_ROOT%{_mandir}/man1/dpkg-${file}.1
done
# remove extraneous build products - sbin
for file in start-stop-daemon install-info cleanup-info update-alternatives; do
    rm -f $RPM_BUILD_ROOT%{_sbindir}/${file}
    rm -f $RPM_BUILD_ROOT%{_mandir}/man8/${file}.8
done
# remove extraneous build products - misc
rm -f $RPM_BUILD_ROOT%{_mandir}/man5/dselect.cfg.5
rm -f $RPM_BUILD_ROOT%{_mandir}/man5/deb-old.5
rm -rf $RPM_BUILD_ROOT%{_sysconfdir}/alternatives
rm -rf $RPM_BUILD_ROOT%{_sysconfdir}/dpkg/origins
rm -rf $RPM_BUILD_ROOT%{_libdir}/dpkg/parsechangelog
# remove extraneous build products - admindir
#rm -rf $RPM_BUILD_ROOT/usr/local

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root)
%{_bindir}/*
%{_sbindir}/*
%{_mandir}/man1/*
%{_mandir}/man5/*
%{_mandir}/man8/*
%{_sysconfdir}/*
%{_datadir}/*
%{_libdir}/*
