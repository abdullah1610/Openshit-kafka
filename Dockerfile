FROM quay.io/strimzi/kafka:0.51.0-kafka-4.1.1

USER root

# Plugins directory and ownership fix
RUN mkdir -p /opt/kafka/plugins/debezium /opt/kafka/plugins/jdbc && \
    chown -R 1001:0 /opt/kafka/plugins

COPY debezium-connector-oracle-2.5.0.Final-plugin.tar.gz /tmp/
COPY kafka-connect-jdbc-10.6.0.jar /opt/kafka/plugins/jdbc/

RUN tar -xzf /tmp/debezium-connector-oracle-2.5.0.Final-plugin.tar.gz -C /opt/kafka/plugins/debezium && \
    rm /tmp/debezium-connector-oracle-2.5.0.Final-plugin.tar.gz

# Download Oracle JDBC driver and place in libs and plugins
RUN curl -L -o /opt/kafka/libs/ojdbc8.jar https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar && \
    curl -L -o /opt/kafka/libs/orai18n.jar https://repo1.maven.org/maven2/com/oracle/database/nls/orai18n/19.3.0.0/orai18n-19.3.0.0.jar && \
    curl -L -o /opt/kafka/libs/xmlparserv2.jar https://repo1.maven.org/maven2/com/oracle/database/xml/xmlparserv2/19.3.0.0/xmlparserv2-19.3.0.0.jar && \
    cp /opt/kafka/libs/ojdbc8.jar /opt/kafka/plugins/ && \
    cp /opt/kafka/libs/orai18n.jar /opt/kafka/plugins/ && \
    cp /opt/kafka/libs/xmlparserv2.jar /opt/kafka/plugins/

# Ensure Strimzi can write configs and plugin files and provide log4j config
RUN mkdir -p /opt/kafka/custom-config && \
    cat > /opt/kafka/custom-config/log4j.properties <<'EOF'
log4j.rootLogger=INFO, stdout
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=[%d] %p %c %x - %m%n
EOF
RUN chown -R 1001:0 /opt/kafka && chmod -R g+rwX /opt/kafka

USER 1001