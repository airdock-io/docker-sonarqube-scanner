FROM openjdk:8-alpine

ENV SONAR_SCANNER_VERSION=4.3.0.2102

WORKDIR /var

RUN apk --no-cache add --update unzip \
    && wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION.zip \
    && unzip sonar-scanner-cli-$SONAR_SCANNER_VERSION.zip \
    && mv sonar-scanner-$SONAR_SCANNER_VERSION sonar-scanner \
    && rm -rf sonar-scanner-cli-$SONAR_SCANNER_VERSION.zip \
    && rm -rf /var/cache/apk/*

ENV PATH=/var/sonar-scanner/bin:$PATH
ENV JAVA_HOME=/usr

CMD ["sonar-scanner", "-h"]
