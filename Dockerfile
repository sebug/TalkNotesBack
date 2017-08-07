# escape=`
FROM microsoft/dotnet-framework:4.6.2 AS build

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Install-WindowsFeature NET-Framework-45-Core
RUN Invoke-WebRequest "https://aka.ms/vs/15/release/vs_BuildTools.exe" -OutFile vs_BuildTools.exe -UseBasicParsing ; `
	Start-Process -FilePath 'vs_BuildTools.exe' -ArgumentList '--quiet', '--norestart', '--locale en-US' -Wait ; `
	Remove-Item .\vs_BuildTools.exe ; `
	Remove-Item -Force -Recurse 'C:\Program Files (x86)\Microsoft Visual Studio\Installer'
RUN setx /M PATH $($Env:PATH + ';' + ${Env:ProgramFiles(x86)} + '\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin')

RUN Install-WindowsFeature NET-Framework-45-ASPNET
RUN Install-WindowsFeature Web-Asp-Net45

RUN Invoke-WebRequest https://download.microsoft.com/download/4/3/B/43B61315-B2CE-4F5B-9E32-34CCA07B2F0E/NDP452-KB2901951-x86-x64-DevPack.exe -OutFile NDP452-KB2901951-x86-x64-DevPack.exe -UseBasicParsing

RUN Start-Process .\NDP452-KB2901951-x86-x64-DevPack.exe -Wait -ArgumentList '/q /norestart'

COPY TalkNotesBack TalkNotesBack

WORKDIR TalkNotesBack

RUN msbuild /p:Configuration=Release

RUN mkdir C:\Published

RUN dir

RUN Copy-Item -Recurse bin C:\Published\bin

RUN Copy-Item *.svc C:\Published

RUN Copy-Item web.config C:\Published

FROM microsoft/iis:windowsservercore-10.0.14393.1480
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

COPY --from=build C:\Published TalkNotesBack

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]
