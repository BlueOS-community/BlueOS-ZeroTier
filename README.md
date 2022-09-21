# This is a fork!

This was quickly put together in order to allow setting up ZeroTier on a BlueOS instance.

To install, do:

`red-pill`

`docker run -d --name zerotier-one --device=/dev/net/tun --net=host  --restart=unless-stopped   --cap-add=NET_ADMIN --cap-add=SYS_ADMIN   -v /var/lib/zerotier-one:/var/lib/zerotier-one williangalvani/zerotier`

