# escape=`

FROM microsoft/iis
SHELL ["powershell", "-command"]

# Install ASP.NET
RUN Install-WindowsFeature NET-Framework-45-ASPNET; `
    Install-WindowsFeature Web-Asp-Net45; `
    Install-WindowsFeature NET-WCF-HTTP-Activation45

EXPOSE 8082

RUN Remove-Website -Name 'Default Web Site'; `
    md 'C:\TalkNotesBack'; `
    New-Website -Name 'TalkNotesBack' `
                -Port 8082 -PhysicalPath 'C:\TalkNotesBack' `
                -ApplicationPool '.NET v4.5'

COPY TalkNotesBack\bin\Release\PublishOutput TalkNotesBack

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]
