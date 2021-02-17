FROM i386/debian:buster as builder

COPY snx_install.sh .
RUN apt-get update
RUN apt-get install -y bzip2 libx11-6 libstdc++5
RUN ./snx_install.sh


FROM i386/debian:buster

COPY --from=builder /usr/bin/snx /usr/bin/
RUN apt-get update && \
	apt-get install -y libx11-6 libstdc++5 \
	iptables net-tools iputils-ping \
	expect \
	kmod

COPY snx.sh /usr/local/bin/
CMD ["snx.sh"]
