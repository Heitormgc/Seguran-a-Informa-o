FROM mysql:8.4

RUN microdnf install -y iproute && microdnf clean all

COPY entrypoint-custom.sh /usr/local/bin/entrypoint-custom.sh
RUN chmod +x /usr/local/bin/entrypoint-custom.sh

ENTRYPOINT ["/usr/local/bin/entrypoint-custom.sh"]
CMD ["mysqld"]
