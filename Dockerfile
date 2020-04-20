FROM alpine

# --------------------------------------------------------------------------
# This Dockerfile performs the following build actions:
# - Clone Shinobi from https://gitlab.com/Shinobi-Systems/Shinobi.git
# - Install Shinobi npm packages 
# - Replace 'localhost' with ${SHINOBI_SERVER_IP} in Yolo plugin config file
# 
# It serves to run the yolo plugin, configured to connect to an instance of
# shinboi running on a separate machine / container. 
#
# Usage:
# docker build --build-arg SHINOBI_SERVER_IP=<ip> -t yolo_alpine_shinobi .
# docker run --rm -it yolo_alpine_shinobi /bin/ash
#
# /opt/shinobi/plugins/yolo # sh INSTALL.sh 
# /opt/shinobi/plugins/yolo # node shinobi-yolo.js
#
# Issue:
# ------
# The plugin compiles successfully but reports an exception at runtime:
# uncaughtException Error: Error relocating /opt/shinobi/plugins/yolo/node_modules/node-yolo-shinobi/build/Release/nodeyolojs.node: make_iseg_layer: symbol not found
#    at Object.Module._extensions..node (module.js:682:18)
#    at Module.load (module.js:566:32)
#    at tryModuleLoad (module.js:506:12)
#    at Function.Module._load (module.js:498:3)
#    at Module.require (module.js:597:17)
#    at require (internal/module.js:11:18)
#    at Object.<anonymous> (/opt/shinobi/plugins/yolo/node_modules/node-yolo-shinobi/index.js:1:82)
#    at Module._compile (module.js:653:30)
#    at Object.Module._extensions..js (module.js:664:10)
#    at Module.load (module.js:566:32)
# 2020-04-20T12:36:50.884Z 'Yolo' 'Plugin started on Port 8082'
#
# Output of ldd nodeyolojs.node is:
# /opt/shinobi/plugins/yolo/node_modules/node-yolo-shinobi/build/Release # ldd nodeyolojs.node
#        ldd (0x7f58f4f40000)
#        libstdc++.so.6 => /usr/lib/libstdc++.so.6 (0x7f58f4962000)
#        libc.musl-x86_64.so.1 => ldd (0x7f58f4f40000)
#        libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x7f58f4750000)
# Error relocating nodeyolojs.node: napi_create_promise: symbol not found
# Error relocating nodeyolojs.node: napi_get_value_string_utf8: symbol not found
# Error relocating nodeyolojs.node: make_iseg_layer: symbol not found
# Error relocating nodeyolojs.node: napi_set_element: symbol not found
# Error relocating nodeyolojs.node: napi_module_register: symbol not found
# Error relocating nodeyolojs.node: napi_delete_async_work: symbol not found
# Error relocating nodeyolojs.node: napi_get_cb_info: symbol not found
# Error relocating nodeyolojs.node: napi_create_int32: symbol not found
# Error relocating nodeyolojs.node: napi_get_new_target: symbol not found
# Error relocating nodeyolojs.node: napi_create_object: symbol not found
# Error relocating nodeyolojs.node: napi_create_double: symbol not found
# Error relocating nodeyolojs.node: napi_reject_deferred: symbol not found
# Error relocating nodeyolojs.node: napi_create_async_work: symbol not found
# Error relocating nodeyolojs.node: napi_set_named_property: symbol not found
# Error relocating nodeyolojs.node: napi_resolve_deferred: symbol not found
# Error relocating nodeyolojs.node: napi_new_instance: symbol not found
# Error relocating nodeyolojs.node: napi_throw_error: symbol not found
# Error relocating nodeyolojs.node: napi_typeof: symbol not found
# Error relocating nodeyolojs.node: napi_wrap: symbol not found
# Error relocating nodeyolojs.node: napi_create_array_with_length: symbol not found
# Error relocating nodeyolojs.node: napi_delete_reference: symbol not found
# Error relocating nodeyolojs.node: napi_unwrap: symbol not found
# Error relocating nodeyolojs.node: napi_create_string_utf8: symbol not found
# Error relocating nodeyolojs.node: napi_get_reference_value: symbol not found
# Error relocating nodeyolojs.node: napi_queue_async_work: symbol not found
# Error relocating nodeyolojs.node: napi_define_class: symbol not found
# Error relocating nodeyolojs.node: napi_create_reference: symbol not found
#
# Seems to be a linking error, cannot find yolo/libyolo.a ??
# --------------------------------------------------------------------------


# --------------------------------------------------------------------------
# IP address of host running Shinobi
# --------------------------------------------------------------------------
ARG SHINOBI_SERVER_IP

# --------------------------------------------------------------------------
# Install Shinobi modules and prepare config for yolo plugin
# so that host refers to ${SHINOBI_SERVER_IP}
# --------------------------------------------------------------------------
RUN apk update \
    && apk add --no-cache \
        build-base \
        curl \
        g++ \
        git \
        imagemagick \
        libc6-compat \
        make \
        npm \
        python2 \
    \
    && git clone -b master --single-branch \
        https://gitlab.com/Shinobi-Systems/Shinobi.git /opt/shinobi/ \
    \
    && cd /opt/shinobi \
    && npm install --unsafe-perm \
    && cp conf.sample.json conf.json \
    \
    && cd /opt/shinobi/plugins/yolo \
    && cp conf.sample.json conf.json \
    && sed -i "s/localhost/${SHINOBI_SERVER_IP}/g" conf.json

# --------------------------------------------------------------------------
# Set working directory of container to yolo plugin
# --------------------------------------------------------------------------
WORKDIR /opt/shinobi/plugins/yolo
