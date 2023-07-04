# syntax=docker/dockerfile:1

FROM busybox:latest
COPY --chmod=755 <<EOF /app/run.sh
    #!/bin/sh
    while true; do
    echo -ne "The time is now $(date +%T)\\r"
    sleep 1
    done
    EOF

ENTRYPOINT /app/run.sh

FROM mcr.microsoft.com/dotnet/sdk:7.0 as build-env
WORKDIR /src
COPY src/*.csproj .
RUN dotnet restore
COPY src .
RUN dotnet publish -c Release -o /publish

FROM mcr.microsoft.com/dotnet/aspnet:7.0 as runtime
WORKDIR /publish
COPY --from=build-env /publish .
EXPOSE 80
ENTRYPOINT ["dotnet", "myWebApp.dll"]