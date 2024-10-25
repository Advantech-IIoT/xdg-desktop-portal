FROM advantechiiot/imx-yocto-sdk:kirkstone

WORKDIR /src
ENTRYPOINT ["/sdk_setenv.sh"]