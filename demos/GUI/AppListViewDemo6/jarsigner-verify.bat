set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_151
path %JAVA_HOME%\bin;%path%
cd C:\android\workspace\AppListViewDemo6
jarsigner -verify -verbose -certs C:\android\workspace\AppListViewDemo6\bin\AppListViewDemo6-release.apk
