>**NOTE:** This is a [BlueOS Extension](https://blueos.cloud/docs/blueos/1.1/extensions/) for using the [ZeroTier](https://www.zerotier.com/) service on a BlueOS device. It sets up a VPN to access your device from anywhere with an internet connection.

### WARNING:

The 12.1.2 update makes the extension use a different folder for persistence. In order to stay connected to your previous Networks, run

`red-pill`

`sudo mkdir -p /usr/blueos/extensions/zerotier && sudo cp -r /var/lib/zerotier-one/* /usr/blueos/extensions/zerotier`

## Initial Setup

1. Install [the ZeroTier extension](https://docs.bluerobotics.com/BlueOS-Extensions-Repository/#:~:text=ZeroTier,Maintainer) on your vehicle
1. [Download ZeroTier](https://www.zerotier.com/download/) on the device(s) you want to connect with
1. [Log In](https://my.zerotier.com/login) to ZeroTier online
    - create an account if you haven't used ZeroTier before)
1. Create a new network and copy the generated network ID
1. Join the network (using the ID) from the BlueOS ZeroTier Extension page, as well as through the ZeroTier interface on your device(s)
1. If using a private network, return to the online ZeroTier interface, scroll down to the "Members" section, and allow each device access to the network by checking the "Auth?" checkbox beside its listing
    - For ease of future management, it may help to give meaningful names and/or descriptions to the devices in the table
1. You should now be able to access the BlueOS web interface through the ZeroTier connection
    - You can use the **vehicle**'s mDNS address (e.g. http://blueos.local, by default), or the **vehicle**'s "Managed IP" shown in ZeroTier's online interface (in the "Members" section)
    - Connecting through ZeroTier requires both ends of the connection to be on the same ZeroTier network and connected to the internet
1. Configure the desired endpoints (for MAVLink telemetry, video streams, serial, etc) to point to the intended recipient
    - Setting up a video stream requires setting up a stream endpoint for it in the [Video Streams](https://blueos.cloud/docs/blueos/1.1/advanced-usage/#video-streams) page
        - Creating a new stream endpoint while connected to BlueOS through the ZeroTier connection will automatically use the connected **device**'s IP address
        - You can also get the relevant **device** IP address(es) through the ZeroTier online interface (in the "Managed IPs" column)
        - BlueOS video streams can provide multiple endpoints of the same type, to send to multiple devices
            - You can edit a stream to add more endpoints
    - Vehicle telemetry+control through QGroundControl is generally handled via a UDP Client link set up in BlueOS's [MAVLink Endpoints](https://blueos.cloud/docs/blueos/1.1/advanced-usage/#mavlink-endpoints) page
        - Creating a new UDP Client endpoint while connected through the ZeroTier connection will automatically use the connected **device**'s IP address
        - You can also get the relevant **device** IP address through the ZeroTier online interface (in the "Managed IPs" column)
    - It is technically also possible to set up a MAVLink connection using BlueOS's GCS Server Link, although it may be less robust
        - Doing this requires adding a "Comm Link" in QGroundControl's Application Settings (instead of creating a new endpoint in BlueOS)
            - you can add the server as the **vehicle**'s mDNS address (e.g. `blueos.local`) or the **vehicle**'s IP address, and leave the port as `14550`
        - Make sure the GCS Server Link is enabled in BlueOS

## General Usage

Once the network and endpoints have been configured it should be possible to reconnect at will, whenever the vehicle and a device are both connected to the internet, and connected to a ZeroTier network they're both authorised on.

If a device leaves a ZeroTier network (or is not connected to the internet) then it will not be accessible to the rest of the network. ZeroTier's online manager can be used to de-authorise devices and/or remove them from the network entirely.

## Troubleshooting

- If the ZeroTier Status is showing as `ACCESS_DENIED`, you're connected to a privately configured ZeroTier network and the network owner (likely yourself) needs to authorise your device through the "Members" section of ZeroTier's online interface for that network
- If the connection is not working it can help to check the "Last Seen" column of the "Members" section of ZeroTier's online interface, to determine whether one or multiple of your devices is not currently connected to the ZeroTier network (it may be having internet connectivity issues, or may just need to connect to the network through its ZeroTier interface)
    - If you can't find your device's ZeroTier interface, it may be an icon in your taskbar / menubar
- Determining which device is which in ZeroTier's online interface requires knowing which order they attempted to join the network, or having access to the devices so you can identify them by disconnecting them from the network (or the internet) and seeing which one changes in the "Last Seen" column
- If the connection is working but some of the endpoints aren't, make sure the endpoints are configured to use the correct IP address
    - Something on the vehicle sending/connecting to a device (e.g. video, GCS MAVLink UDP client link for telemetry, etc) needs to be directed towards the **device**'s IP address
    - Using a device to connect to the vehicle (e.g. to access the BlueOS web interface, or connect to a GCS server link for telemetry) needs to use the **vehicle**'s IP or mDNS address