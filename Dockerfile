#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/core/runtime:3.1-buster-slim AS base
RUN apt-get update && apt-get install -y libfreetype6
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src

COPY Source/Service/Service.csproj Source/Service/
COPY Source/Common/Engine/Engine.csproj Source/Common/
COPY Source/Common/Engine.Common/Engine.Common.csproj Source/Common/
COPY Source/Common/Engine.Messaging/Engine.Messaging.csproj Source/Common/

COPY lib/linux/SDK/libglasswall.classic.so lib/linux/SDK/
COPY Source/Service/libfreetype.so.6 Source/Service/libfreetype.so.6
RUN dotnet restore Source/Service/Service.csproj 

COPY . .
WORKDIR /src/Source/Service
RUN dotnet build Service.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish Service.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

USER 1001:1001

ENTRYPOINT ["dotnet", "Service.dll"]
