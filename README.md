# devstack-plugin-cinder-image-cache
DevStack plugin for configuring the Cinder Glance Image Cache

http://docs.openstack.org/developer/devstack/plugins.html

## How to use

Add the following to your local.conf:

    [[local|localrc]]
    CINDER_INTERNAL_TENANT_PASSWORD=mySecretPassword
    enable_plugin cinder-image-cache https://github.com/patrick-east/devstack-plugin-cinder-image-cache.git master

See devstack-plugin-cinder-image-cache/devstack/settings for a list of
environment variables that can be used. By default the plugin will create a
Cinder internal tenant and configure all enabled backends to use the cache.

At a minimum it is recommended to specify a CINDER_INTERNAL_TENANT_PASSWORD.
