# SSH Tunnel

Permanent reverse SSH tunnel from Omnia to a server.


## Requirements

- Public ssh-accessible server
- A user with `authorized_keys` from Omnia added
    - `command="/bin/true" ` restriction is enough
- `GatewayPorts` enabled in `sshd_config`
- One desired port opened (in firewall rules)


## Installation

1. Place `ssh-tunnel.sh` to `/root` directory
2. Configure desired values in `/root/ssh-tunnel.sh`
    - `server`: Remote server
    - `user`: Remote ssh user
    - `port`: Port on the remote server that would be opened
3. Copy`ssh-tunnel.init` to `/etc/init.d/ssh-tunnel`
4. Enable and start the service
    ```sh
    /etc/init.d/ssh-tunnel enable
    /etc/init.d/ssh-tunnel start
    ```


## Usage

Connect to the router through the server and the opened port:

```sh
ssh -l root -p 12345 remote.server.pub
```
