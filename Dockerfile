FROM openjdk:8-alpine

ENV SONAR_SCANNER_VERSION=4.3.0.2102

WORKDIR /var

COPY sonar-scanner-entrypoint.sh /usr/local/bin/sonar-scanner-entrypoint

RUN apk --no-cache add --update unzip openssl\
    && wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION.zip \
    && unzip sonar-scanner-cli-$SONAR_SCANNER_VERSION.zip \
    && mv sonar-scanner-$SONAR_SCANNER_VERSION sonar-scanner \
    && rm -rf sonar-scanner-cli-$SONAR_SCANNER_VERSION.zip \
    && rm -rf /var/cache/apk/* \
    && chmod +x /usr/local/bin/sonar-scanner-entrypoint

ENV PATH=/var/sonar-scanner/bin:$PATH
ENV JAVA_HOME=/usr

ENTRYPOINT ["sonar-scanner-entrypoint"]
CMD ["sonar-scanner"]
