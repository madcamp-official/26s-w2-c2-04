# 로컬 백엔드/프런트엔드 연동 테스트용 이미지.
# docker-compose.yml(레포 루트)에서 postgres/redis와 함께 띄웁니다.

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Backend.csproj ./
RUN dotnet restore Backend.csproj

COPY . .
RUN dotnet publish Backend.csproj -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Npgsql가 GSS 암호화 협상 시 libgssapi_krb5를 찾는데, aspnet 베이스 이미지에는
# 없어서 (치명적이진 않지만) 에러 로그가 남습니다. 조용히 넘어가도록 설치해둡니다.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libgssapi-krb5-2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "Backend.dll"]
