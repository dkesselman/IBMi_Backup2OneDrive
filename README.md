# IBMi_Backup2OneDrive

Well... this is similar to https://github.com/dkesselman/IBMi_Cloud_Backup , but using OneDrive as a target, because there are lot of people using Office365 and they have 1TB per seat. It's a nice amount of storage for development purposes.

# Requirements

In this case we use the project "onedrivecmd" and Python 3, so you need to install:

* OpenSSH (5733-SC1) and start SSH
* YUM (install the software)
* GIT (download the project)
* PIGZ (compression)
* ReadLine (input data)
* Python3

Once you've installed OpenSSH and YUM (I recommend using IBM Access Client Solutions) you can run from your BASH command line (remember to tune your PATH):

yum install git pigz readline python3

Next, you need to install "onedrivecmd":

/QOpenSys/pkgs/bin/pip3 install onedrivecmd

And now you can download this scripts and change permissions:

chmod +x mnuod*

Now you can run:

./mnuod.sh

![OneDrive Backup Menu](https://github.com/dkesselman/IBMi_Backup2OneDrive/blob/main/IBMi_Backup2OneDrive.gif "IBM i Backup to OneDrive - Menu")


Good luck!
