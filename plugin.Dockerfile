FROM registry.access.redhat.com/ubi9-minimal

COPY debezium-connector-oracle-2.5.0.Final-plugin.tar.gz /tmp/
COPY kafka-connect-jdbc-10.6.0.jar /tmp/

RUN microdnf install -y tar gzip && \
    mkdir /oracle-plugin && \
    tar -xzf /tmp/debezium-connector-oracle-2.5.0.Final-plugin.tar.gz -C /oracle-plugin && \
    cp -R /oracle-plugin/* / && \
    cp /tmp/kafka-connect-jdbc-10.6.0.jar / && \
    rm -rf /tmp /oracle-plugin && \
    microdnf clean all
