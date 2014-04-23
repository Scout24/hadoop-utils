Name: hadoop-utils
Version: __VERSION__
Release: 1__EXTRAREV__
Summary: Generate hadoop-utils RPM package
Group: Applications/System
URL: https://github.com/ImmobilienScout24/hadoop-utils
Source0: %{name}-%{version}.tar.gz
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
Requires: rpm, rpm-build

%description
hadoop-utils is a set of tools that come in handy when administrating and running
a hadoop cluster

%prep
%setup -q

%build
make test

%install
umask 0002
rm -rf $RPM_BUILD_ROOT
install -m 0755 chown_subdirs_in_dir -D $RPM_BUILD_ROOT/usr/bin/chown_subdirs_in_dir

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/usr/bin/chown_subdirs_in_dir
