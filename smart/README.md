# S.M.A.R.T. configuration

Short *howto* manual to monitor your disks in the *Turris NAS box*.


## Packages to install

- Needed packages are:
    - `smartmontools`
    - `smartd`
- Packages are included in *NAS user list*


## Configuration

- TurrisOS distribution lacks *smartd warning script* for sending mail
  notifications from `smartd`
- Place `smartd_warning.sh` into `etc` directory (`/etc/smartd_warning.sh`)

- Configure `smartd` in `/etc/smartd.conf`, i.e.:

    ```config
    ## smartd.conf
    #

    # send test mails on start
    DEFAULT -m root -M test

    # schedule short selftest each week and long selftest each month
    /dev/sda -d sat -a -s (S/../(07|14|21|28)/./02|L/../01/./02)
    /dev/sdb -d sat -a -s (S/../(08|15|22|29)/./02|L/../02/./02)
    ```

- Restart the service

    ```sh
    /etc/init.d/smartd stop
    /etc/init.d/smartd start
    ```
