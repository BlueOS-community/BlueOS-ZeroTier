# vim: ft=dockerfile

FROM debian:buster as stage

ARG PACKAGE_BASEURL=https://download.zerotier.com/debian/buster/pool/main/z/zerotier-one/
ARG ARCH=amd64
ARG VERSION

LABEL version="1.0"
LABEL permissions="--net=host --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v /var/lib/zerotier-one:/var/lib/zerotier-one"

RUN apt-get update -qq && apt-get install curl -y
RUN curl -sSL -o zerotier-one.deb "${PACKAGE_BASEURL}/zerotier-one_${VERSION}_${ARCH}.deb"

FROM debian:buster

RUN apt-get update -qq && apt-get install openssl libssl1.1 -y

COPY --from=stage zerotier-one.deb .

RUN dpkg -i zerotier-one.deb && rm -f zerotier-one.deb
RUN echo "${VERSION}" >/etc/zerotier-version
RUN rm -rf /var/lib/zerotier-one

COPY entrypoint.sh.release /entrypoint.sh
RUN chmod 755 /entrypoint.sh

COPY web /web

RUN cd web && pip install .

LABEL authors '[\
    {\
        "name": "Willian Galvani",\
        "email": "willian@bluerobotics.com"\
    }\
]'
LABEL docs ''
LABEL company '{\
        "about": "",\
        "name": "Blue Robotics",\
        "email": "support@bluerobotics.com"\
    }'
LABEL readme 'https://raw.githubusercontent.com/Williangalvani/ZeroTierOne/{tag}/README.md'
LABEL website 'https://github.com/williangalvani/zerotierone'
LABEL support 'https://github.com/williangalvani/zerotierone'
LABEL requirements "core >  1"

HEALTHCHECK --interval=1s CMD bash /healthcheck.sh


CMD []
ENTRYPOINT ["/entrypoint.sh"]
