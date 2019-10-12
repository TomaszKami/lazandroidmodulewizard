export JAVA_HOME=${/usr/libexec/java_home}
export PATH=${JAVA_HOME}/bin:$PATH
cd /android/workspace/AppFTPClientDemo1
keytool -genkey -v -keystore appftpclientdemo1-release.keystore -alias appftpclientdemo1.keyalias -keyalg RSA -keysize 2048 -validity 10000 < /android/workspace/AppFTPClientDemo1/keytool_input.txt
