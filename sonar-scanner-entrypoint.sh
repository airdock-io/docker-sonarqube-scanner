#!/usr/bin/env sh

docker_process_init_files() {
	echo
	local f
	for f; do
		case "$f" in
			*.sh)
				# https://github.com/docker-library/postgres/issues/450#issuecomment-393167936
				# https://github.com/docker-library/postgres/pull/452
				if [ -x "$f" ]; then
					echo "$0: running $f"
					"$f"
				else
					echo "$0: sourcing $f"
					. "$f"
				fi
				;;
			*)        echo "$0: ignoring $f" ;;
		esac
		echo
	done
}
[ -d "/docker-entrypoint-init.d" ] && docker_process_init_files /docker-entrypoint-init.d/*

docker_add_certs() {
	echo
	export SONAR_SCANNER_TRUSTSTORE=/usr/local/sonarqube.jks
	export SONAR_SCANNER_STOREPASS=$(openssl rand -base64 32)
	export SONAR_SCANNER_OPTS="-Djavax.net.ssl.trustStore=${SONAR_SCANNER_TRUSTSTORE} -Djavax.net.ssl.trustStorePassword=${SONAR_SCANNER_STOREPASS}"
	local f
	for f; do
		openssl x509 -in $f -out "$f.pem" -outform PEM >> /dev/stdout
		keytool -import -noprompt -trustcacerts -alias sonarqube -storepass $SONAR_SCANNER_STOREPASS -keystore $SONAR_SCANNER_TRUSTSTORE -file "$f.pem" >> /dev/stdout
		echo "[IMPORTANT] TrustStore is located: ${SONAR_SCANNER_TRUSTSTORE}"
		echo "[IMPORTANT] Use SONAR_SCANNER_STOREPASS and SONAR_SCANNER_TRUSTSTORE env vars to integrate to any command"
		echo
	done
}
[ -d "/docker-entrypoint-certs.d" ] && echo "Adding certs to TrustStore from /docker-entrypoint-certs.d/*" >> /dev/stdout && docker_add_certs /docker-entrypoint-certs.d/*
[ ! -d "/docker-entrypoint-certs.d" ] && echo "No Certs to add to TrustStore"

# Resume to "official" entrypoint
echo "Resuming to old entrypoint" >> /dev/stdout
echo "$@" >> /dev/stdout
exec "$@"
