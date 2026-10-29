FROM advantechiiot/imx-yocto-sdk:wrynose

WORKDIR /src
ENTRYPOINT ["/sdk_setenv.sh"]