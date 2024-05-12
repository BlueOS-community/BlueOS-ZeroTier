# vim: ft=dockerfile

FROM debian:buster as stage

ARG PACKAGE_BASEURL=https://download.zerotier.com/debian/buster/pool/main/z/zerotier-one/

COPY download.sh /download.sh
RUN chmod +x /download.sh && /download.sh
FROM bluerobotics/blueos-base:v0.0.9

RUN apt-get update -qq && apt-get install openssl libssl1.1 -y

COPY --from=stage zerotier-one.deb .

RUN dpkg -i zerotier-one.deb && rm -f zerotier-one.deb
RUN echo VERSION=1.14.0 >/etc/zerotier-version
RUN rm -rf /var/lib/zerotier-one

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

COPY web /web

RUN cd web && pip install .


LABEL permissions='\
{\
    "NetworkMode":"host"\
    ,"HostConfig":{\
        "Privileged": true,\
        "NetworkMode":"host",\
        "CapAdd":["SYS_ADMIN","NET_ADMIN"],\
        "Binds":["/usr/blueos/extensions/zerotier:/var/lib/zerotier-one","/var/lib/zerotier-one:/old-settings"],\
        "Devices":[\
            {\
                "PathOnHost":"/dev/net/tun",\
                "PathInContainer":"/dev/net/tun",\
                "CgroupPermissions":"rwm"\
            }\
        ]\
    }\
} '
LABEL authors='[\
    {\
        "name": "Willian Galvani",\
        "email": "willian@bluerobotics.com"\
    }\
]'
LABEL company='{\
        "about": "",\
        "name": "Blue Robotics",\
        "email": "support@bluerobotics.com"\
    }'
LABEL type="other"
LABEL tags='[\
        "communication"\
    ]'
LABEL readme='https://raw.githubusercontent.com/Williangalvani/ZeroTierOne/{tag}/README.md'
LABEL links='{\
        "website": "https://github.com/Williangalvani/zerotierone",\
        "support": "https://github.com/Williangalvani/zerotierone/issues"\
    }'

LABEL requirements="core >= 1.1"


HEALTHCHECK --interval=1s CMD bash /healthcheck.sh


CMD []
ENTRYPOINT ["/entrypoint.sh"]
