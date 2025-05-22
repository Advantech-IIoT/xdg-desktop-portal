FROM advantechiiot/imx-yocto-sdk:scarthgap

WORKDIR /src
ENTRYPOINT ["/sdk_setenv.sh"]