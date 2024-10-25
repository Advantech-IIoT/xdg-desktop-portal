FROM advantechiiot/imx-yocto-sdk:mickledore

WORKDIR /src
ENTRYPOINT ["/sdk_setenv.sh"]