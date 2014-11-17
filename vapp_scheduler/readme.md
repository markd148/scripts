<h1>vCloud vApp Scheduler</h1>

Powershell scripts to power vcloud Director vApps on and off according to a schedule.

<h2>Introduction</h2>
<p>
Many customers wish to take advantage of the Skyscape’s hourly billing by turning VMs off when they are not in use. Currently there is no global functionality in the Skyscape platform to automate this for customers however it can be relatively easily achieved using the vCloud Director API.
To assist customers with this Skyscape have written a PowerShell script which allows a range of vApps to be powered on and off according to a schedule. This document explains how the process works and what is required to install and configure the script.
</p>
<h2>How It Works</h2>

<p>Customers create a CSV (vapplist.csv) file containing a list of vApps which need controlling along with their Organization ID and the time at which each vApp should be powered on or off.
Customers run the “SaveCredentials.ps1” script to capture the Organization login credentials to an encrypted file in the “creds” directory
Customers configure a Windows scheduled task to run the vAppScheduler.ps1 script at regular intervals (every 5 minutes or so)
Every 5 minutes (or whatever interval was specified) the script cycles through “vapplist.csv” logging in to vCloud Orgs to check whether the vApp is running or not. If the time window specified in “vapplist.csv” dictates that vApp should be running and the script deems that it is not then the script will start the vApp immediately. Likewise if the script deems that the vApp should not be running then it will stop it immediately.
The script operates at a vApp level. This means that all VMs in the vApp will be powered on or off together. This is by design. Operating on an entire vApp means that the script has to make less calls to the vCloud API and is therefore more performant. It also means that customers can retain control over boot order and delays within the vApp via the vCloud portal.</p>

<h2>Requirements</h2>

<ul>
<li>A Tiny Windows VM which supports running PowerShell scripts</li>
<li>VMware PowerCLI  5.0 or later</li>
<li>Login Credentials for each vCloud Organization hosting VMs you wish to automate</li>
<li>The vAppScheduler.ps1 script</li>
<li>The SaveCredentials.ps1 script</li>
</ul>

<h2>Getting Started:</h2>

<h3>1. Install git on your local machine:</h3>
http://git-scm.com/book/en/v2/Getting-Started-Installing-Git

<h3>2. Install PowerCLI</h3>
http://buildvirtual.net/install-and-configure-vsphere-powercli-5-x/

<h3>3. Open PowerCLI and clone this repository</h3>
<code>git clone https://github.com/tlawrence/scripts</code>

<h3>4. Create a directory to store scripts and config & copy scripts over</h3>

`PowerCLI C:\GIT\scripts> mkdir c:\automation`  
`PowerCLI C:\GIT\scripts> copy vapp_scheduler\*.ps1 c:\automation`


<h3>5. Change directory and create 'creds' subdirectory</h3>
<code>
PowerCLI C:\GIT\scripts> cd c:\automation
PowerCLI C:\GIT\scripts> mkdir creds
</code>

<h3>6. Create a scheduled task to run vAppScheduler.ps1 frequently (every 5 minutes is recommended)</h3>

