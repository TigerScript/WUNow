# wunow

This is a powershell script for performing an immediate windows update, 
especially useful for new image builds, or PPM runs.

I run it using a simple one-liner in a powershell administrator console:

iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TigerScript/wunow/master/wunow.ps1'))

